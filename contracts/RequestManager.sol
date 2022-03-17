//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./libraries/Geo.sol";

import "./FundV1.sol";
import "./FundManager.sol";
import "./DynamicChecks.sol";
import "./Registry.sol";

import "hardhat/console.sol";

contract RequestManager is AccessControl, DynamicChecks {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using EnumerableSet for EnumerableSet.Bytes32Set;

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

    struct Request {
        uint256 id;
        uint256 fundId;
        uint256 amount;
        address token;
        address recipient;
        Status status;
        Geo.Coordinates location;
        EnumerableSet.Bytes32Set checks;
        EnumerableSet.Bytes32Set pending;
        mapping(bytes32 => address) approvals;
    }

    constructor(bytes32[] memory _defaultChecks)
        DynamicChecks(_defaultChecks)
    {}

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
    )
        public
        requireChecks /* onlyOpenFunds */
        returns (uint256)
    {
        // pre-allocate storage location for the new Request
        uint256 index = requests.length;
        requests.push();

        // assign new Request to the storage location
        Request storage request = requests[index];

        request.id = index;
        request.status = Status.Pending;
        request.location = Geo.coordinatesFromPair(_coordinates);
        request.recipient = _recipient;
        request.fundId = _fundId;
        request.amount = _amount;
        request.token = _tokenAddress;

        uint256 length = checks.length;

        uint256 i = 0;
        while (i < length) {
            request.checks.add(checks[i]);
            request.pending.add(checks[i]);
            i++;
        }

        emit RequestCreated(
            index,
            _fundId,
            _recipient,
            _amount,
            _tokenAddress,
            _description
        );

        return index;
    }

    /**
     * @dev            initiate a request
     * @param  _id     type of the request
     * @param  _check  check to approve
     * @return         boolean indicating op result
     */
    function approveRequest(uint256 _id, bytes32 _check)
        public
        onlyRole(APPROVER_ROLE)
        onlyRequestsWithStatus(Status.Pending, _id)
        returns (bool)
    {
        Request storage request = requests[_id];

        if (!_isApprovable(request, _check)) revert NotAllowed();

        _approveCheck(request, _check);

        emit CheckApproved(_id, _check);

        if (request.pending.length() == 0) {
            _bumpStatus(request);
        }

        if (request.status == Status.Approved) {
            //_finalizeRequest();
        }

        return true;
    }

    /**
     * @dev         get request status
     * @param  _id  request ID
     * @return      request status
     */
    function getStatus(uint256 _id) external view returns (Status) {
        return requests[_id].status;
    }

    /**
     * @dev         get approval status
     * @param  _id  request ID
     * @return      tuple of (pending, all) checks
     */
    function getApprovalStatus(uint256 _id)
        external
        view
        returns (uint256, uint256)
    {
        return (requests[_id].pending.length(), requests[_id].checks.length());
    }

    /**
     * @dev         get remaining checks for a request
     * @param  _id  request ID
     * @return      remaining checks
     */
    function getRemainingChecks(uint256 _id)
        external
        view
        returns (bytes32[] memory)
    {
        return requests[_id].pending.values();
    }

    /**
     * @dev         get approved checks for a request
     * @param  _id  request ID
     * @return      approved checks
     */
    function getApprovedChecks(uint256 _id)
        external
        view
        returns (bytes32[] memory, address[] memory)
    {
        Request storage request = requests[_id];
        uint256 allChecksLength = request.checks.length();
        uint256 pendingChecksLength = allChecksLength -
            request.pending.length();

        bytes32[] memory checks = new bytes32[](pendingChecksLength);
        address[] memory approvers = new address[](pendingChecksLength);

        for (uint256 i = 0; i < allChecksLength; i++) {
            bytes32 check = request.checks.at(i);
            if (request.pending.contains(check)) continue;
            checks[i] = check;
            approvers[i] = request.approvals[check];
        }

        return (checks, approvers);
    }

    /**
     * @dev            get approver address for a check
     * @param  _id     request ID
     * @param  _check  check
     * @return         remaining checks
     */
    function getApprover(uint256 _id, bytes32 _check)
        external
        view
        returns (address)
    {
        return requests[_id].approvals[_check];
    }

    // -----------------------------------------------------------------
    // INTERNAL API
    // -----------------------------------------------------------------

    function _isApprovable(Request storage _request, bytes32 _check)
        internal
        view
        returns (bool)
    {
        return
            _request.pending.contains(_check) &&
            _request.approvals[_check] == address(0);
    }

    function _approveCheck(Request storage _request, bytes32 _check) internal {
        _request.approvals[_check] = msg.sender;
        _request.pending.remove(_check);
    }

    function _bumpStatus(Request storage _request) internal {
        if (uint8(_request.status) == uint8(type(Status).max))
            revert NotAllowed();

        _request.status = Status(uint8(_request.status) + 1);

        emit StatusChange(_request.id, _request.status);
    }

    // -----------------------------------------------------------------
    // MODIFIERS
    // -----------------------------------------------------------------

    modifier onlyRequestsWithStatus(Status _status, uint256 _requestId) {
        if (requests[_requestId].status != _status) revert NotAllowed();
        _;
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event RequestCreated(
        uint256 indexed id,
        uint256 indexed fundId,
        address indexed recipient,
        uint256 amount,
        address token,
        string description
    );

    event CheckApproved(uint256 indexed id, bytes32 indexed check);

    event StatusChange(uint256 indexed id, Status indexed status);
}
