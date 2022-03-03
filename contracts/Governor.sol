//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract DynamicChecks is AccessControl {
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
        require(checks.length > 1, "CANT_REMOVE_ALL_CHECKS");
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
        require(_initialChecks.length > 0);

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
        _approve(_requestId, _checkIndex);

        return true;
    }

    function finalizeRequest(uint256 _requestId)
        public
        onlyRole(FINALIZER_ROLE)
        onlyRequestsWithStatus(RequestStatus.Pending, _requestId)
        returns (bool)
    {
        // TODO: FINALIZE FLOW
        requests[_requestId].requestStatus = RequestStatus.Finalized;
        return true;
    }

    function signRequest(uint256 _requestId)
        public
        onlyRole(EXECUTOR_ROLE)
        onlyRequestsWithStatus(RequestStatus.Finalized, _requestId)
        returns (bool)
    {
        // TODO: SIGN FLOW
        requests[_requestId].requestStatus = RequestStatus.Executed;
        return true;
    }

    // -----------------------------------------------------------------
    // INTERNAL
    // -----------------------------------------------------------------

    function _signRequest(uint256 _requestId)
        internal
        onlyRole(EXECUTOR_ROLE)
        onlyRequestsWithStatus(RequestStatus.Finalized, _requestId)
        returns (bool)
    {
        // TODO: INTERNAL SIGN FLOW
    }

    function _approve(uint256 _requestId, uint256 _checkIndex) internal {
        bytes32 check = requests[_requestId].remainingChecks[_checkIndex];

        require(
            requests[_requestId].approvals[check] != address(0x0),
            "ALREADY_APPROVED"
        );

        requests[_requestId].approvals[check] = msg.sender;

        _shiftPop(requests[_requestId].remainingChecks, _checkIndex);
    }

    // -----------------------------------------------------------------
    // MODIFIERS
    // -----------------------------------------------------------------

    modifier requireChecks() {
        require(
            checks.length > 0,
            "NO_REQUESTS_ALLOWED_WITHOUT_PREDEFINED_CHECKS"
        );
        _;
    }

    modifier onlyRequestsWithStatus(
        RequestStatus _requestStatus,
        uint256 _requestId
    ) {
        require(
            requests[_requestId].requestStatus == _requestStatus,
            "CALL_NOT_ALLOWED_FOR_REQUEST_STATUS"
        );

        _;
    }
}
