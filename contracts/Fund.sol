//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./TokenControl.sol";

import "hardhat/console.sol";

contract Fund is AccessControl, TokenControl {
    error NotAllowedForStatus();

    enum Status {
        Open,
        Paused,
        Closed
    }

    string public id;
    string public name;
    Status public status;

    address private safeAddress;

    constructor(
        string memory _id,
        string memory _name,
        address[] memory _owners,
        address[] memory _allowedTokens
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        id = _id;
        name = _name;

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

        return address(this);
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
