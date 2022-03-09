//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./TokenControl.sol";
import "./Fund.sol";

import "hardhat/console.sol";

contract FundManager is AccessControl, TokenControl {
    address[] private funds;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev                   get a fund's deposit address
     * @param  _id            unique identifier of the fund
     * @param  _tokenAddress  address of token tracker
     * @return                address of the fund
     */
    function getDepositAddressFor(uint256 _id, address _tokenAddress)
        public
        view
        returns (address)
    {
        return Fund(funds[_id]).getDepositAddressFor(_tokenAddress);
    }

    /**
     * @dev          get a fund's deposit address
     * @param  _id   unique identifier of a fund
     * @return       deposit address for a fund
     */
    function getFundAddress(uint256 _id) public view returns (address) {
        return funds[_id];
    }

    // -----------------------------------------------------------------
    // ADMIN API
    // -----------------------------------------------------------------

    /**
     * @dev                    setup a new fund
     * @param  _name           name of the fund
     * @param  _focus          focus of the fund
     * @param  _allowedTokens  array of allowed token addresses
     * @param  _safeAddress    address of underlying Gnosis Safe
     * @return                 address of the deployed fund
     */
    function setupFund(
        string memory _name,
        string memory _focus,
        address[] memory _allowedTokens,
        address _safeAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256, address) {
        uint256 index = funds.length;

        Fund fund = new Fund(
            index,
            _name,
            _focus,
            _allowedTokens,
            _safeAddress,
            msg.sender
        );

        funds.push(address(fund));

        return (index, address(fund));
    }
}
