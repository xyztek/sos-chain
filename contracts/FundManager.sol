//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./FundV1.sol";
import "./Registered.sol";
import "./TokenControl.sol";

import "hardhat/console.sol";

error NotFound();

contract FundManager is AccessControl, Registered {
    address public baseFund;
    address[] private funds;

    constructor(address _registry, address _impl) Registered(_registry) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        baseFund = _impl;
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    function getFunds() public view returns (address[] memory) {
        return funds;
    }

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
     * @return       address
     */
    function getFundAddress(uint256 _id) public view returns (address) {
        return funds[_id];
    }

    /**
     * @dev          get a list of allowed tokens for a fund
     * @param  _id   unique identifier of a fund
     * @return       list of addresses
     */
    function getAllowedTokens(uint256 _id)
        public
        view
        returns (address[] memory)
    {
        return FundV1(funds[_id]).getAllowedTokens();
    }

    /**
     * @dev                    check if token is allowed
     * @param  _id             unique identifier of a fund
     * @param  _tokenAddress   token address
     * @return                 boolean
     */
    function isTokenAllowed(uint256 _id, address _tokenAddress)
        public
        view
        returns (bool)
    {
        return FundV1(funds[_id]).isTokenAllowed(_tokenAddress);
    }

    // -----------------------------------------------------------------
    // ADMIN API
    // -----------------------------------------------------------------

    function hashFund(
        string memory _name,
        string memory _focus,
        string memory _description
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(_name, _focus, _description)));
    }

    /**
     * @dev                    setup a new fund
     * @param  _name           name of the fund
     * @param  _focus          focus of the fund
     * @param  _description    description of the fund
     * @param  _allowedTokens  array of allowed token addresses
     * @param  _safeAddress    address of underlying Gnosis Safe
     */
    function createFund(
        string memory _name,
        string memory _focus,
        string memory _description,
        address[] memory _allowedTokens,
        address _safeAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 index = funds.length;

        address cloneAddress = Clones.clone(baseFund);

        FundV1(cloneAddress).initialize(
            index,
            _name,
            _focus,
            _description,
            _allowedTokens,
            _safeAddress,
            msg.sender
        );

        funds.push(cloneAddress);

        emit FundCreated(index, cloneAddress, _name, _focus, _description);
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
        baseFund = _impl;
        return true;
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event FundCreated(
        uint256 indexed id,
        address indexed at,
        string name,
        string focus,
        string description
    );
}
