//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "hardhat/console.sol";

contract TokenControl is AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private allowedTokens;

    /**
     * @dev             return a list of allowed token
                        contract addresses
     */
    function getTokens() public view returns (address[] memory) {
        return allowedTokens.values();
    }

    /**
     * @dev             add a token to the list of allowed tokens
     * @param _address  token contract address
     */
    function addToken(address _address)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        return allowedTokens.add(_address);
    }

    /**
     * @dev             remove a token from the list of allowed tokens
     * @param _address  token contract address
     */
    function removeToken(address _address)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        return allowedTokens.add(_address);
    }
}
