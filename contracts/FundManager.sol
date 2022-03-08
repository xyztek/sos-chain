//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./TokenControl.sol";
import "./Fund.sol";

import "hardhat/console.sol";

contract FundManager is AccessControl, TokenControl {
    mapping(string => address) private funds;

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
    function getDepositAddressFor(
        string memory _id,
        address _tokenAddress // usdc
    ) public view returns (address) {
        return Fund(funds[_id]).getDepositAddressFor(_tokenAddress);
    }

    /**
     * @dev          get a fund's deposit address
     * @param  _id   unique identifier of a fund
     * @return       deposit address for a fund
     */
    function getFundAddress(string memory _id) public view returns (address) {
        return funds[_id];
    }

    // -----------------------------------------------------------------
    // ADMIN API
    // -----------------------------------------------------------------

    /**
     * @dev             setup a new fund
     * @param  _id      unique identifier of the fund
     * @param  _name    name of the fund
     * @param  _tokens  array of token addresses for the fund
     * @param  _safe    safe address of the fund
     * @return          address of the deployed fund
     */
    function setupFund(
        string memory _id,
        string memory _name,
        address[] memory _tokens,
        address _safe
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (address) {
        Fund fund = new Fund(_id, _name, _tokens, _safe, msg.sender);
        funds[_id] = address(fund);

        return address(fund);
    }
}
