//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Fund.sol";
import "./FundManager.sol";
import "./DynamicChecks.sol";
import "./Registry.sol";

import "hardhat/console.sol";

contract Governor is AccessControl, DynamicChecks {
    using SafeMath for uint256;

    error MissingRole(bytes32);
    error DisallowedStatusChange();
    error NotAllowedForRequest(RequestStatus);
    error NotAllowedForFund(uint256);
    error CheckAlreadyApproved();

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
    // Does this RESOLUTION value make sense?
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
        uint256 fundId;
        bytes32[] remainingChecks;
        mapping(bytes32 => address) approvals;
    }

    Request[] private requests;
    Registry private registry;

    constructor(address _registry, bytes32[] memory _initialChecks) {
        if (_initialChecks.length > 0) revert NoZeroChecks();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        checks = _initialChecks;
        registry = Registry(_registry);
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    function initRequest(
        bytes32 _requestType,
        address _recipient,
        uint256 _fundId,
        uint256[2] memory coordinates
    ) public requireChecks onlyOpenFunds(_fundId) returns (uint256) {
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
        request.fundId = _fundId;
        request.remainingChecks = checks;

        return index;
    }

    // -----------------------------------------------------------------
    // OWNER API
    // -----------------------------------------------------------------

    function approveRequest(
        uint256 _fundId,
        uint256 _requestId,
        uint256 _checkIndex
    )
        public
        onlyFundRole(_fundId, APPROVER_ROLE)
        onlyRequestsWithStatus(RequestStatus.Pending, _requestId)
        returns (bool)
    {
        _approveRequest(_requestId, _checkIndex);

        if (requests[_requestId].requestStatus == RequestStatus.Approved) {
            _finalizeRequest(_requestId);
        }

        return true;
    }

    function finalizeRequest(uint256 _fundId, uint256 _requestId)
        public
        onlyFundRole(_fundId, FINALIZER_ROLE)
        onlyRequestsWithStatus(RequestStatus.Approved, _requestId)
        returns (bool)
    {
        _finalizeRequest(_requestId);

        return true;
    }

    function signRequest(uint256 _fundId, uint256 _requestId)
        public
        onlyFundRole(_fundId, EXECUTOR_ROLE)
        onlyRequestsWithStatus(RequestStatus.Finalized, _requestId)
        returns (bool)
    {
        _signRequest(_requestId);
        return true;
    }

    // -----------------------------------------------------------------
    // INTERNAL
    // -----------------------------------------------------------------
    function _getFund(uint256 _fundId) internal view returns (Fund) {
        address fundManagerAddress = registry.get("FUND_MANAGER");
        address fundAddress = FundManager(fundManagerAddress).getFundAddress(
            _fundId
        );

        return Fund(fundAddress);
    }

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
            revert CheckAlreadyApproved();

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

    modifier onlyOpenFunds(uint256 _fundId) {
        Fund fund = _getFund(_fundId);
        if (!fund.isOpen()) revert NotAllowedForFund(_fundId);
        _;
    }

    modifier onlyFundRole(uint256 _fundId, bytes32 _role) {
        Fund fund = _getFund(_fundId);
        if (!fund.hasRole(_role, msg.sender)) revert MissingRole(_role);
        _;
    }

    modifier onlyRequestsWithStatus(
        RequestStatus _requestStatus,
        uint256 _requestId
    ) {
        if (requests[_requestId].requestStatus != _requestStatus)
            revert NotAllowedForRequest(_requestStatus);
        _;
    }
}
