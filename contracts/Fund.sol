//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./TokenControl.sol";

import "hardhat/console.sol";

contract Fund is AccessControl, TokenControl {
    error NotAllowedForStatus();
    error NotSet();

    enum Status {
        Open,
        Paused,
        Closed
    }

    uint256 public id;
    string public name;
    string public focus;
    Status public status;

    address private safeAddress;

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    constructor(
        uint256 _id,
        string memory _name,
        string memory _focus,
        address[] memory _allowedTokens,
        address _safe,
        address _owner
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        id = _id;
        name = _name;
        focus = _focus;
        safeAddress = _safe;

        uint256 i = 0;
        while (i < _allowedTokens.length) {
            addToken(_allowedTokens[i]);
            i++;
        }
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev                   get metadata for a fund
     * @return                metadata of the fund
     */
    function getMeta() external view returns (string memory, string memory) {
        return (name, focus);
    }

    /**
     * @dev                   get deposit address for a token
     * @param  _tokenAddress  tracker address of the token to deposit
                              (must be an allowed token)
     * @return                deposit address for a token
     */
    function getDepositAddressFor(address _tokenAddress)
        external
        view
        returns (address)
    {
        if (status != Status.Open) revert NotAllowedForStatus();
        if (!isTokenAllowed(_tokenAddress)) revert TokenNotAllowed();
        if (safeAddress == address(0x0)) revert NotSet();
        return safeAddress;
    }

    /**
     * @dev                   check if a fund is open for donations
     * @return                boolean indicating status
     */
    function isOpen() external view returns (bool) {
        return status == Status.Open;
    }

    // -----------------------------------------------------------------
    // ADMIN API
    // -----------------------------------------------------------------

    /**
     * @dev             pause fund
     * @return          boolean indicating result of the operation
     */
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (status != Status.Open) revert NotAllowedForStatus();

        return _setStatus(Status.Paused);
    }

    /**
     * @dev             resume fund
     * @return          boolean indicating result of the operation
     */
    function resume() external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (status != Status.Paused) revert NotAllowedForStatus();

        return _setStatus(Status.Open);
    }

    /**
     * @notice          this is final, a closed fund cannot be reopened
     * @dev             close fund
     * @return          boolean indicating result of the operation
     */
    function close() external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (status == Status.Closed) revert NotAllowedForStatus();
        return _setStatus(Status.Closed);
    }

    // -----------------------------------------------------------------
    // INTERNAL API
    // -----------------------------------------------------------------

    /**
     * @dev             set fund status
     * @param  _status  status to set
     * @return          boolean indicating result of the operation
     */
    function _setStatus(Status _status) internal returns (bool) {
        status = _status;

        return true;
    }
}
