//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./libraries/Geo.sol";

import "./FundV1.sol";
import "./FundManager.sol";
import "./DynamicChecks.sol";
import "./Registry.sol";

import "hardhat/console.sol";

enum RequestStatus {
    Pending,
    Approved,
    Finalized,
    Executed
}

struct Request {
    uint256 id;
    uint256 fundId;
    bytes32 _type;
    RequestStatus status;
    Geo.Coordinates location;
    address recipient;
    uint256 amount;
    bytes32[] remainingChecks;
    mapping(bytes32 => address) approvals;
}

contract RequestManager is AccessControl, DynamicChecks {
    Request[] private requests;

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    constructor(bytes32[] memory _defaultChecks)
        DynamicChecks(_defaultChecks)
    {}

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev                    initiate a request
     * @param  _type           type of the request
     * @param  _amount         requested amount from the fund
     * @param  _recipient      ultimate recipient of the funds requested
     * @param  _fundId         id of the fund requested from
     * @param  _coordinates    coordinates pointing to request location
     * @return                 id (index) of the initiated request
     */
    function createRequest(
        bytes32 _type,
        uint256 _amount,
        address _recipient,
        uint256 _fundId,
        uint256[2] memory _coordinates
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
        request._type = _type;
        request.status = RequestStatus.Pending;
        request.location = Geo.coordinatesFromPair(_coordinates);
        request.recipient = _recipient;
        request.fundId = _fundId;
        request.amount = _amount;
        request.remainingChecks = checks;

        emit RequestCreated(index, _fundId, _recipient);

        return index;
    }

    /**
     * @dev                 initiate a request
     * @param  _id          type of the request
     * @param  _checkIndex  index of the check being approved
     * @return              boolean indicating result of the operation
     */
    function approveRequest(uint256 _id, uint256 _checkIndex)
        public
        onlyRole(APPROVER_ROLE)
        onlyRequestsWithStatus(RequestStatus.Pending, _id)
        returns (bool)
    {
        bytes32 check = requests[_id].remainingChecks[_checkIndex];

        if (requests[_id].approvals[check] != address(0x0))
            revert CheckAlreadyApproved();

        requests[_id].approvals[check] = msg.sender;

        _shiftPop(requests[_id].remainingChecks, _checkIndex);

        if (requests[_id].remainingChecks.length == 0) {
            _bumpRequestStatus(_id);
        }

        if (requests[_id].status == RequestStatus.Approved) {
            _finalizeRequest(_id);
        }

        return true;
    }

    function getRequestStatus(uint256 _id) public view returns (RequestStatus) {
        return requests[_id].status;
    }

    // -----------------------------------------------------------------
    // INTERNAL API
    // -----------------------------------------------------------------

    function _bumpRequestStatus(uint256 _requestId) internal {
        if (
            uint8(requests[_requestId].status) == uint8(type(RequestStatus).max)
        ) revert NotAllowed();

        requests[_requestId].status = RequestStatus(
            uint8(requests[_requestId].status) + 1
        );

        //emit RequestStatusChange(_requestId, requests[_requestId].status);
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

    modifier onlyRequestsWithStatus(RequestStatus _status, uint256 _requestId) {
        if (requests[_requestId].status != _status) revert NotAllowed();
        _;
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event RequestCreated(
        uint256 indexed id,
        uint256 indexed fundId,
        address indexed recipient
    );

    event RequestStatusChange(uint256 indexed id, RequestStatus indexed status);
}
