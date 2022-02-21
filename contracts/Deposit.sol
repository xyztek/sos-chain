//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Deposit {
    /**
     * @dev             map tokens allowed for deposit
     * @param string    token symbol
     * @param address   token contract address
     */
    mapping(bytes32 => address) public allowedTokens;

    /**
     * @dev             add a token to the list of allowed tokens
     * @param string    token symbol
     * @param address   token contract address
     */
    function allowTokenDeposit(bytes32 symbol_, address address_) public onlyOwner returns (bool) {
        allowedTokens[symbol_] = address_;

        return true;
    }

    /**
     * @dev             remove a token from the list of allowed tokens
     * @param string    token symbol
     */
    function disallowTokenDeposit(bytes32 symbol_) public onlyOwner returns (bool) {
        require(allowedTokens[symbol_] != 0x0);

        delete(allowedTokens[symbol_]);

        return true;
    }
}
