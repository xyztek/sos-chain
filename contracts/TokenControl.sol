//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "hardhat/console.sol";

contract TokenControl is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    error TokenNotAllowed();

    EnumerableSet.AddressSet private allowedTokens;

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev             list of allowed token contract addresses
     * @return          return a list of allowed token contract addresses
     */
    function getAllowedTokens() public view returns (address[] memory) {
        return allowedTokens.values();
    }

    /**
     * @dev              add a token to the list of allowed tokens
     * @param  _address  tracker address of the token
     * @return           boolean indicating if a token is allowed for deposit
     */
    function isTokenAllowed(address _tokenAddress) public view returns (bool) {
        return allowedTokens.contains(_tokenAddress);
    }

    // -----------------------------------------------------------------
    // ADMIN API
    // -----------------------------------------------------------------

    /**
     * @dev               add a token to the list of allowed tokens
     * @param   _address  tracker address of the token
     * @return            boolean indicating result of the operation
     */
    function addToken(address _address)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        return allowedTokens.add(_address);
    }

    /**
     * @dev              remove a token from the list of allowed tokens
     * @param  _address  tracker address of the token
     * @return           boolean indicating result of the operation
     */
    function removeToken(address _address)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        return allowedTokens.add(_address);
    }
}
