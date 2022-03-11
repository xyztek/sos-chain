//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./TokenControl.sol";
import "./FundV1.sol";

import "hardhat/console.sol";

contract FundManager is AccessControl {
    address public fundImplementation;
    address[] private funds;

    constructor(address _impl) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        fundImplementation = _impl;
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
        return FundV1(funds[_id]).getDepositAddressFor(_tokenAddress);
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
     */
    function createFund(
        string memory _name,
        string memory _focus,
        address[] memory _allowedTokens,
        address _safeAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 index = funds.length;

        address cloneAddress = Clones.clone(fundImplementation);

        FundV1(cloneAddress).initialize(
            index,
            _name,
            _focus,
            _allowedTokens,
            _safeAddress,
            msg.sender
        );

        funds.push(cloneAddress);

        emit FundCreated(index, cloneAddress, _name);
    }

    /**
     * @dev           set implementation address
     * @param  _impl  address of underlying Gnosis Safe
     * @return        boolean indicating op. result
     */

    function setImplementation(address _impl)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (bool)
    {
        fundImplementation = _impl;
        return true;
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event FundCreated(
        uint256 indexed id,
        address indexed at,
        string indexed name
    );
}
