//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract DynamicChecks is AccessControl {
    error NoZeroChecks();

    bytes32 public constant AUDIT_ROLE = keccak256("AUDIT_ROLE");
    bytes32[] internal checks;

    function getCheck(uint256 _index) public view returns (bytes32) {
        return checks[_index];
    }

    function allChecks() public view returns (bytes32[] memory) {
        return checks;
    }

    function addCheck(bytes32 _check)
        public
        onlyRole(AUDIT_ROLE)
        returns (bool)
    {
        checks.push(_check);

        return true;
    }

    function removeCheck(uint256 _index)
        public
        onlyRole(AUDIT_ROLE)
        returns (bool)
    {
        if (checks.length <= 1) revert NoZeroChecks();

        _shiftPop(checks, _index);
        return true;
    }

    function _shiftPop(bytes32[] storage _array, uint256 _index) internal {
        require(_array.length > 0);
        require(_index <= _array.length - 1);

        _array[_index] = _array[_array.length - 1];
        _array.pop();

        // TODO: ENSURE _array IS PASSED AS REFERENCE IN TESTS
    }
}

contract Governor is AccessControl, DynamicChecks {
    using SafeMath for uint256;

    error DisallowedStatusChange();
    error NotAllowedForRequestStatus();
    error RequestAlreadyApproved();

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    enum RequestStatus {
        Pending,
        Approved,
        Finalized,
        Executed
    }

    // This will be used for coordinate math.
    uint256 private constant RESOLUTION = 1000000000000000;

    struct Coordinates {
        uint256 lat;
        uint256 lon;
    }

    struct Request {
        bytes32 requestType;
        Coordinates requestLocation;
        RequestStatus requestStatus;
        address recipient;
        bytes32[] remainingChecks;
        mapping(bytes32 => address) approvals;
    }

    Request[] private requests;

    constructor(bytes32[] memory _initialChecks) {
        if (_initialChecks.length > 0) revert NoZeroChecks();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        checks = _initialChecks;
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    function initRequest(
        bytes32 _requestType,
        address _recipient,
        uint256[2] memory coordinates
    ) public requireChecks returns (uint256) {
        // pre-allocate storage location for the new Request
        uint256 index = requests.length;
        requests.push();

        // assign new Request to the storage location
        Request storage request = requests[index];

        request.requestType = _requestType;
        request.requestStatus = RequestStatus.Pending;
        request.requestLocation = Coordinates({
            lat: coordinates[0],
            lon: coordinates[1]
        });
        request.recipient = _recipient;
        request.remainingChecks = checks;

        return index;
    }

    // -----------------------------------------------------------------
    // OWNER API
    // -----------------------------------------------------------------

    function approveRequest(uint256 _requestId, uint256 _checkIndex)
        public
        onlyRole(APPROVER_ROLE)
        onlyRequestsWithStatus(RequestStatus.Pending, _requestId)
        returns (bool)
    {
        _approveRequest(_requestId, _checkIndex);

        if (requests[_requestId].requestStatus == RequestStatus.Approved) {
            _finalizeRequest(_requestId);
        }

        return true;
    }

    function finalizeRequest(uint256 _requestId)
        public
        onlyRole(FINALIZER_ROLE)
        onlyRequestsWithStatus(RequestStatus.Approved, _requestId)
        returns (bool)
    {
        _finalizeRequest(_requestId);

        return true;
    }

    function signRequest(uint256 _requestId)
        public
        onlyRole(EXECUTOR_ROLE)
        onlyRequestsWithStatus(RequestStatus.Finalized, _requestId)
        returns (bool)
    {
        _signRequest(_requestId);
        return true;
    }

    // -----------------------------------------------------------------
    // INTERNAL
    // -----------------------------------------------------------------

    function _bumpRequestStatus(uint256 _requestId) internal {
        if (requests[_requestId].requestStatus == RequestStatus.Pending) {
            requests[_requestId].requestStatus = RequestStatus.Approved;
        } else if (
            requests[_requestId].requestStatus == RequestStatus.Approved
        ) {
            requests[_requestId].requestStatus = RequestStatus.Finalized;
        } else if (
            requests[_requestId].requestStatus == RequestStatus.Finalized
        ) {
            requests[_requestId].requestStatus = RequestStatus.Executed;
        } else {
            revert DisallowedStatusChange();
        }
    }

    function _approveRequest(uint256 _requestId, uint256 _checkIndex)
        internal
        onlyRequestsWithStatus(RequestStatus.Pending, _requestId)
    {
        bytes32 check = requests[_requestId].remainingChecks[_checkIndex];

        if (requests[_requestId].approvals[check] != address(0x0))
            revert RequestAlreadyApproved();

        requests[_requestId].approvals[check] = msg.sender;

        _shiftPop(requests[_requestId].remainingChecks, _checkIndex);

        if (requests[_requestId].remainingChecks.length == 0) {
            _bumpRequestStatus(_requestId);
        }
    }

    function _finalizeRequest(uint256 _requestId)
        internal
        onlyRequestsWithStatus(RequestStatus.Approved, _requestId)
    {
        // TODO: INTERNAL FINALIZE FLOW

        _bumpRequestStatus(_requestId);
    }

    function _signRequest(uint256 _requestId)
        internal
        onlyRequestsWithStatus(RequestStatus.Finalized, _requestId)
    {
        // TODO: INTERNAL SIGN FLOW

        _bumpRequestStatus(_requestId);
    }

    // -----------------------------------------------------------------
    // MODIFIERS
    // -----------------------------------------------------------------

    modifier requireChecks() {
        if (checks.length < 1) revert NoZeroChecks();
        _;
    }

    modifier onlyRequestsWithStatus(
        RequestStatus _requestStatus,
        uint256 _requestId
    ) {
        if (requests[_requestId].requestStatus != _requestStatus)
            revert NotAllowedForRequestStatus();
        _;
    }
}
