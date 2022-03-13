//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./TokenControl.sol";

import "hardhat/console.sol";

error Forbidden();
error NotAllowed();

enum Status {
    Open,
    Paused,
    Closed
}

// Master Fund (v1) Contract
// FundManager create clones of this contract.
contract FundV1 is AccessControl, TokenControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public id;

    string public name;
    string public focus;
    string public description;
    Status public status;

    address private factory;
    address private safeAddress;

    // called once by the factory at time of deployment
    // any subsequent calls will revert with Forbidden()
    function initialize(
        uint256 _id,
        string memory _name,
        string memory _focus,
        string memory _description,
        address[] memory _allowedTokens,
        address _safeAddress,
        address _owner
    ) external {
        if (factory != address(0)) revert Forbidden();
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);

        id = _id;
        factory = msg.sender;

        name = _name;
        focus = _focus;
        description = _description;
        safeAddress = _safeAddress;
        status = Status.Open;

        uint256 i = 0;
        while (i < _allowedTokens.length) {
            allowedTokens.add(_allowedTokens[i]);
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
    function getMeta()
        external
        view
        returns (
            string memory,
            string memory,
            string memory
        )
    {
        return (name, focus, description);
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
        if (status != Status.Open) revert NotAllowed();
        if (!isTokenAllowed(_tokenAddress)) revert NotAllowed();
        if (safeAddress == address(0)) revert NotAllowed();
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
        if (status != Status.Open) revert NotAllowed();

        return _setStatus(Status.Paused);
    }

    /**
     * @dev             resume fund
     * @return          boolean indicating result of the operation
     */
    function resume() external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (status != Status.Paused) revert NotAllowed();

        return _setStatus(Status.Open);
    }

    /**
     * @notice          this is final, a closed fund cannot be reopened
     * @dev             close fund
     * @return          boolean indicating result of the operation
     */
    function close() external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        if (status == Status.Closed) revert NotAllowed();
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
