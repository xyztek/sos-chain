//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./TokenControl.sol";
import "./DynamicChecks.sol";

import "hardhat/console.sol";

error Forbidden();
error NotAllowed();

// Master Fund (v1) Contract
// FundManager create clones of this contract.
contract FundV1 is AccessControl, TokenControl, DynamicChecks {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    Status public status;
    address private factory;
    address private safeAddress;
    string public name;
    string public focus;

    bool public requestable;

    enum Status {
        Open,
        Paused,
        Closed
    }

    // called once by the factory at time of deployment
    // any subsequent calls will revert with Forbidden()
    function initialize(
        string memory _name,
        string memory _focus,
        address[] memory _allowedTokens,
        bool _requestable,
        bytes32[] memory _checks,
        address _safeAddress,
        address _owner
    ) external {
        if (factory != address(0)) revert Forbidden();
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);

        factory = msg.sender;

        requestable = _requestable;
        name = _name;
        focus = _focus;
        safeAddress = _safeAddress;
        status = Status.Open;
        setChecks(_checks);

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
    function getMeta() external view returns (string memory, string memory) {
        return (name, focus);
    }

    /**
     * @dev                   get fund safe balances
     * @return                tuple of (tokenAddress[], balance[])
     */
    function getBalances()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 length = allowedTokens.length();

        address[] memory addresses = new address[](length);
        uint256[] memory balances = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            addresses[i] = allowedTokens.at(i);
            balances[i] = IERC20(allowedTokens.at(i)).balanceOf(safeAddress);
        }

        return (addresses, balances);
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
    // ACCESS CONTROLLED
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
    // INTERNAL
    // -----------------------------------------------------------------

    /**
     * @dev             set fund status
     * @param  _status  status to set
     * @return          boolean indicating result of the operation
     */
    function _setStatus(Status _status) internal returns (bool) {
        status = _status;

        emit StatusChange(uint256(_status));

        return true;
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event StatusChange(uint256 indexed id);
}
