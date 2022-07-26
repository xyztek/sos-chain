//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {FundV1} from "./FundV1.sol";
import {FundManagerV1} from "./FundManagerV1.sol";
import {Registry} from "./Registry.sol";
import {Registered} from "./Registered.sol";
import {OracleConsumer as Oracle} from "./hybrid/OracleConsumer.sol";

import {Geo} from "./libraries/Geo.sol";
import {Checks} from "./libraries/Checks.sol";

import "hardhat/console.sol";

contract RequestManager is AccessControl, Registered {
    using SafeMath for uint256;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    error MissingRole(bytes32);
    error NotAllowed();

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    Request[] private requests;

    enum Status {
        Pending,
        Approved,
        Finalized,
        Executed
    }

    struct Signature {
        bool approved;
        address signer;
    }

    struct Request {
        uint256 id;
        uint256 fundId;
        uint256 amount;
        address token;
        address recipient;
        Status status;
        Geo.Coordinates location;
        bytes32[2][] checks;
        uint256 pendingCheckCount;
        mapping(uint256 => Signature) signatures;
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev                   initiate a request
     * @param  _amount        requested amount from the fund
     * @param  _tokenAddress  token address
     * @param  _recipient     ultimate recipient of the funds requested
     * @param  _fundId        id of the fund requested from
     * @param  _description   a short description of the request
     * @param  _coordinates   coordinates pointing to request location
     * @return                id (index) of the initiated request
     */
    function createRequest(
        uint256 _amount,
        address _tokenAddress,
        address _recipient,
        uint256 _fundId,
        uint256[2] memory _coordinates,
        string memory _description
    ) public returns (uint256) {
        FundV1 fund = _getFund(_fundId);
        if (!fund.requestable()) revert NotAllowed();
        if (!fund.isWhitelisted(msg.sender)) revert NotAllowed();

        uint256 id = _createRequest(
            _amount,
            _tokenAddress,
            _recipient,
            _fundId,
            fund,
            _coordinates,
            _description
        );

        return id;
    }

    /**
     * @dev                initiate a request
     * @param  _requestId  type of the request
     * @param  _checkId    check to approve
     * @return             boolean indicating op result
     */
    function approveCheck(
        uint256 _requestId,
        uint256 _checkId,
        bool _success
    ) public returns (bool) {
        Request storage request = requests[_requestId];
        FundV1 fund = _getFund(request.fundId);

        if (!_isApprovable(request, _checkId) || !_isFundOpen(fund))
            revert NotAllowed();

        if (!_hasFundRole(fund, APPROVER_ROLE))
            revert MissingRole(APPROVER_ROLE);

        _approveCheck(request, _checkId, _success);

        if (request.pendingCheckCount == 0) {
            _bumpStatus(request);
        }

        if (request.status == Status.Approved) {
            //_finalizeRequest();
        }

        return true;
    }

    /**
     * @dev                get request status
     * @param  _requestId  request ID
     * @return             request status
     */
    function getStatus(uint256 _requestId) external view returns (Status) {
        return requests[_requestId].status;
    }

    /**
     * @dev                get remaining checks for a request
     * @param  _requestId  request ID
     * @return             remaining check count
     */
    function getPendingChecksCount(uint256 _requestId)
        external
        view
        returns (uint256)
    {
        return requests[_requestId].pendingCheckCount;
    }

    /**
     * @dev              get approver address for a check
     * @param  _id       request ID
     * @param  _checkId  check ID
     * @return           remaining checks
     */
    function getSigner(uint256 _id, uint256 _checkId)
        external
        view
        returns (address)
    {
        return requests[_id].signatures[_checkId].signer;
    }

    /**
     * @dev                call oracle to try approve check
     * @param  _requestId  request ID
     * @param  _checkId    check ID
     */
    function callOracle(uint256 _requestId, uint256 _checkId)
        external
        returns (bool)
    {
        Request storage request = requests[_requestId];
        bytes32[2] memory check = request.checks[_checkId];
        require(Checks.isAutomated(check), "Automated check required.");

        bytes memory data = _packRequestWithCheck(_requestId, _checkId);

        bytes32 oracleRequestId = Oracle(_getAddress("SOS_ORACLE")).tryApprove(
            check[1],
            data
        );

        emit OracleRequest(_requestId, check[1], oracleRequestId, data);

        return true;
    }

    // -----------------------------------------------------------------
    // INTERNAL
    // -----------------------------------------------------------------

    function _isApprovable(Request storage _request, uint256 _checkId)
        internal
        view
        returns (bool)
    {
        return
            _request.status == Status.Pending &&
            _request.signatures[_checkId].approved == false;
    }

    function _isFundOpen(FundV1 _fund) internal view returns (bool) {
        return _fund.isOpen();
    }

    function _hasFundRole(FundV1 _fund, bytes32 _role)
        internal
        view
        returns (bool)
    {
        return _fund.hasRole(_role, msg.sender);
    }

    function _createRequest(
        uint256 _amount,
        address _tokenAddress,
        address _recipient,
        uint256 _fundId,
        FundV1 _fund,
        uint256[2] memory _coordinates,
        string memory _description
    ) internal returns (uint256) {
        // pre-allocate storage location for the new Request
        uint256 id = requests.length;
        requests.push();

        // assign new Request to the storage location
        Request storage request = requests[id];

        request.id = id;
        request.status = Status.Pending;
        request.location = Geo.coordinatesFromPair(_coordinates);
        request.recipient = _recipient;
        request.fundId = _fundId;
        request.amount = _amount;
        request.token = _tokenAddress;

        request.checks = _copyChecksFromFund(_fund);
        request.pendingCheckCount = request.checks.length;

        emit RequestCreated(
            id,
            _fundId,
            _recipient,
            _amount,
            _tokenAddress,
            _description,
            request.checks
        );

        return id;
    }

    function _approveCheck(
        Request storage _request,
        uint256 _checkId,
        bool success
    ) internal {
        require(_request.pendingCheckCount > 0, "No pending checks.");

        if (success) {
            _request.pendingCheckCount = _request.pendingCheckCount.sub(1);
        }

        _request.signatures[_checkId] = Signature({
            approved: success,
            signer: msg.sender
        });

        emit Signed(_request.id, _checkId, msg.sender, success);
    }

    function _bumpStatus(Request storage _request) internal {
        if (uint8(_request.status) == uint8(type(Status).max))
            revert NotAllowed();

        _request.status = Status(uint8(_request.status) + 1);

        emit StatusChange(_request.id, _request.status);
    }

    function _getFund(uint256 _fundId) internal view returns (FundV1) {
        FundManagerV1 manager = FundManagerV1(_getAddress("FUND_MANAGER"));
        address fundAddress = manager.getFundAddress(_fundId);

        return FundV1(fundAddress);
    }

    function _copyChecksFromFund(FundV1 _fund)
        internal
        view
        returns (bytes32[2][] memory)
    {
        return _fund.allChecks();
    }

    function _packRequestWithCheck(uint256 _id, uint256 _checkId)
        public
        view
        returns (bytes memory)
    {
        Request storage request = requests[_id];

        return
            abi.encode(
                _checkId,
                request.id,
                request.status,
                request.location.lat,
                request.location.lon,
                request.recipient,
                request.fundId,
                request.amount,
                request.token
            );
    }

    // -----------------------------------------------------------------
    // MODIFIERS
    // -----------------------------------------------------------------

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event RequestCreated(
        uint256 indexed id,
        uint256 indexed fundId,
        address indexed recipient,
        uint256 amount,
        address token,
        string description,
        bytes32[2][] checks
    );

    event Signed(
        uint256 indexed id,
        uint256 indexed check,
        address indexed approver,
        bool approved
    );

    event OracleRequest(
        uint256 indexed requestId,
        bytes32 indexed jobId,
        bytes32 indexed oracleRequestId,
        bytes data
    );

    event StatusChange(uint256 indexed id, Status indexed status);
}
