//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

import "./FundV1.sol";
import "./Registered.sol";
import "./TokenControl.sol";
import {Checks} from "./libraries/Checks.sol";

import "hardhat/console.sol";

contract FundManagerV1 is AccessControl, Registered, Initializable {
    error NotAllowed();

    address public baseFund;
    address[] private funds;

    struct Fund {
        uint256 id;
        address at;
        string name;
        string focus;
        uint256 status;
    }

    function initialize(bytes memory data) external initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        
        console.logAddress(msg.sender);

        (address _registry,address _impl) = abi.decode(data, (address,address));
        _setRegistry(_registry);
        baseFund = _impl;

}
    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev         get a fund's name and focus
     * @param  _id  unique identifier of the fund
     * @return      fund name and focus
     */
    function getFundMeta(uint256 _id)
        public
        view
        returns (string memory, string memory)
    {
        return FundV1(funds[_id]).getMeta();
    }

    /**
     * @dev     get all fund addresses
     * @return  fund addresses
     */
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
    // ACCESS CONTROLLED
    // -----------------------------------------------------------------

    /**
     * @dev                    setup a new fund
     * @param  _name           name of the fund
     * @param  _focus          focus of the fund
     * @param  _description    description of the fund
     * @param  _safeAddress    address of underlying Gnosis Safe
     * @param  _allowedTokens  array of allowed token addresses
     * @param  _requestable    boolean indicating if fund is requestable
     * @param  _checks         a list of checks if fund is requestable
     */
    function createFund(
        string memory _name,
        string memory _focus,
        string memory _description,
        address _safeAddress,
        address[] memory _allowedTokens,
        bool _requestable,
        bytes32[2][] memory _checks,
        address[] memory _whitelist
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 index = funds.length;

        address cloneAddress = Clones.clone(baseFund);

        FundV1(cloneAddress).initialize(
            _name,
            _focus,
            _safeAddress,
            msg.sender,
            _allowedTokens,
            _requestable,
            _checks,
            _whitelist
        );
        
        funds.push(cloneAddress);
        emit FundCreated(index, cloneAddress, _name, _focus, _description,_requestable);
    }

    /**
     * @dev                    setup a new fund
     * @param  _name           name of the fund
     * @param  _focus          focus of the fund
     * @param  _description    description of the fund
     * @param  _allowedTokens  array of allowed token addresses
     * @param  _owners         owners of the safe
       @param  _threshold      number of confirmations that the safe would need before a transaction
     */
    function createFundWithSafe(
        string memory _name,
        string memory _focus,
        string memory _description,
        address[] memory _allowedTokens,
        bool _requestable,
        bytes32[2][] memory _checks,
        address[] memory _whitelist,
        address[] memory _owners,
        uint256 _threshold
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_threshold > _owners.length) revert NotAllowed();
        uint256 index = funds.length;

        address cloneAddress = Clones.clone(baseFund);

        address _safeAddress = _setupSafe(_owners, _threshold);

        FundV1(cloneAddress).initialize(
            _name,
            _focus,
            _safeAddress,
            msg.sender,
            _allowedTokens,
            _requestable,
            _checks,
            _whitelist
        );

        funds.push(cloneAddress);

        emit FundCreated(index, cloneAddress, _name, _focus, _description,_requestable);
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
    // INTERNAL API
    // -----------------------------------------------------------------

    function _setupSafe(address[] memory _owners, uint256 _threshold)
        internal
        returns (address)
    {
        bytes memory safeParams = _encodeSetup(
            _owners,
            _threshold,
            address(0),
            "0x",
            address(0),
            address(0),
            0,
            payable(address(0))
        );

        return
            address(
                GnosisSafeProxyFactory(_getAddress("GNOSIS_SAFE_PROXY_FACTORY"))
                    .createProxy(_getAddress("GNOSIS_SAFE"), safeParams)
            );
    }

    /**
     * @dev Encodes params and function for proxy creation
     * @param _owners List of Safe owners.
     * @param _threshold Number of required confirmations for a Safe transaction.
     * @param to Contract address for optional delegate call.
     * @param data Data payload for optional delegate call.
     * @param fallbackHandler Handler for fallback calls to this contract
     * @param paymentToken Token that should be used for the payment (0 is ETH)
     * @param payment Value that should be paid
     * @param paymentReceiver Address that should receive the payment (or 0 if tx.origin)
     * @return encoded Bytes representation of the params with setup signature
     */
    function _encodeSetup(
        address[] memory _owners,
        uint256 _threshold,
        address to,
        bytes memory data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) internal pure returns (bytes memory encoded) {
        encoded = abi.encodeWithSignature(
            "setup(address[],uint256,address,bytes,address,address,uint256,address)",
            _owners,
            _threshold,
            to,
            data,
            fallbackHandler,
            paymentToken,
            payment,
            paymentReceiver
        );
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event FundCreated(
        uint256 indexed id,
        address indexed at,
        string name,
        string focus,
        string description,
        bool requestable
    );
}
