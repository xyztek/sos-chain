//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./libraries/Geo.sol";
import "./FundV1.sol";
import "./FundManager.sol";
import "./Registry.sol";
import {OracleConsumer as Oracle} from "./hybrid/OracleConsumer.sol";
import {Checks} from "./libraries/Checks.sol";

import "hardhat/console.sol";

contract RequestManager is AccessControl, Registered {
    using SafeMath for uint256;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    Request[] private requests;

    error MissingRole(bytes32);

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
        uint256 pending;
        mapping(bytes32 => Signature) signatures;
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
     * @param  _check      check to approve
     * @return             boolean indicating op result
     */
    function approveCheck(
        uint256 _requestId,
        bytes32 _check,
        bool _success
    ) public returns (bool) {
        Request storage request = requests[_requestId];
        FundV1 fund = _getFund(request.fundId);

        if (!_isApprovable(request, _check) || !_isFundOpen(fund))
            revert NotAllowed();

        if (!_hasFundRole(fund, APPROVER_ROLE))
            revert MissingRole(APPROVER_ROLE);

        _approveCheck(request, _check, _success);

        if (request.pending == 0) {
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
        return requests[_requestId].pending;
    }

    /**
     * @dev            get approver address for a check
     * @param  _id     request ID
     * @param  _check  check
     * @return         remaining checks
     */
    function getSigner(uint256 _id, bytes32 _check)
        external
        view
        returns (address)
    {
        return requests[_id].signatures[_check].signer;
    }

    /**
     * @dev                call oracle to try approve check
     * @param  _requestId  request ID
     * @param  _check      check
     */
    function callOracle(uint256 _requestId, bytes32 _check)
        external
        returns (bool)
    {
        // require(_check.automated, "Automated check required.");
        // bytes memory data = _packRequestWithCheck(_requestId, _check.name);
        bytes memory data = _packRequestWithCheck(_requestId, _check);
        bytes32 oracleRequestId = Oracle(_getAddress("SOS_ORACLE")).tryApprove(
            //_check.jobId,
            bytes32("JOB_ID"),
            data
        );

        emit OracleRequest(
            _requestId,
            bytes32("JOB_ID"),
            oracleRequestId,
            data
        );
    }

    // -----------------------------------------------------------------
    // INTERNAL
    // -----------------------------------------------------------------

    function _isApprovable(Request storage _request, bytes32 _check)
        internal
        view
        returns (bool)
    {
        return
            _request.status == Status.Pending &&
            _request.signatures[_check].approved == false;
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

        bytes32[] memory checks = _copyChecksFromFund(_fund);
        request.pending = checks.length;

        emit RequestCreated(
            id,
            _fundId,
            _recipient,
            _amount,
            _tokenAddress,
            _description,
            checks
        );

        return id;
    }

    function _approveCheck(
        Request storage _request,
        bytes32 _check,
        bool success
    ) internal {
        require(_request.pending > 0, "No pending checks.");

        if (success) {
            _request.pending = _request.pending.sub(1);
        }

        _request.signatures[_check] = Signature({
            approved: success,
            signer: msg.sender
        });

        emit Signed(_request.id, _check, msg.sender, success);
    }

    function _bumpStatus(Request storage _request) internal {
        if (uint8(_request.status) == uint8(type(Status).max))
            revert NotAllowed();

        _request.status = Status(uint8(_request.status) + 1);

        emit StatusChange(_request.id, _request.status);
    }

    function _getFund(uint256 _fundId) internal view returns (FundV1) {
        FundManager manager = FundManager(_getAddress("FUND_MANAGER"));
        address fundAddress = manager.getFundAddress(_fundId);

        return FundV1(fundAddress);
    }

    function _copyChecksFromFund(FundV1 _fund)
        internal
        view
        returns (bytes32[] memory)
    {
        return _fund.allChecks();
    }

    function _packRequestWithCheck(uint256 _id, bytes32 _check)
        public
        view
        returns (bytes memory)
    {
        Request storage request = requests[_id];

        return
            abi.encode(
                _check,
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
        bytes32[] checks
    );

    event Signed(
        uint256 indexed id,
        bytes32 indexed check,
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
