//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import {Checks} from "./libraries/Checks.sol";
import {TokenControl} from "./TokenControl.sol";

import "./Registered.sol";

// Master Fund (v1) Contract
// FundManager create clones of this contract.
contract FundV1 is AccessControlEnumerable, TokenControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    error NotAllowed();
    error NoZeroChecks();
    error Forbidden();

    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    bytes32 public constant FINALIZER_ROLE = keccak256("FINALIZER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    Status public status;
    address private factory;
    address private safeAddress;
    bool public requestable;
    string public name;
    string public focus;

    address[] private donatedTokens;
    mapping(address => uint256) private balancesMap;

    bytes32[2][] public checks;
    EnumerableSet.AddressSet private whitelist;

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
        address _safeAddress,
        address _owner,
        address[] memory _allowedTokens,
        bool _requestable,
        bytes32[2][] memory _checks,
        address[] memory _whitelist,
        address _factory
    ) external {
        if (factory != address(0)) revert Forbidden();

        if (_requestable) {
            require(
                _checks.length > 0,
                "A set of initial checks are required for a requestable Fund."
            );
        }

        if (_whitelist.length > 0 || _checks.length > 0) {
            require(_requestable, "Fund must be set as requestable.");
        }

        factory = _factory;

        _setupRole(FACTORY_ROLE, factory);

        _setupRole(DEFAULT_ADMIN_ROLE, _owner);
        _setupRole(OWNER_ROLE, _owner);
        _setupRole(AUDITOR_ROLE, _owner);
        _setupRole(APPROVER_ROLE, _owner);
        _setupRole(FINALIZER_ROLE, _owner);
        _setupRole(EXECUTOR_ROLE, _owner);

        requestable = _requestable;
        name = _name;
        focus = _focus;
        safeAddress = _safeAddress;
        status = Status.Open;

        _setChecks(_checks);
        _batchSet(whitelist, _whitelist);
        _batchSet(allowedTokens, _allowedTokens);
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
     * @dev                   get fund total balances
     * @return                array of tokenAddress[]
     */
    function getDonatedTokens() external view returns (address[] memory) {
        return (donatedTokens);
    }

    /**
     * @dev                   get fund total balances
     * @return                uint256 balance of the given token
     */
    function getBalanceForToken(address _tokenAddress)
        external
        view
        returns (uint256)
    {
        return (balancesMap[_tokenAddress]);
    }

    /**
     * @dev                   called from Donation.sol and updates total balance for the given token address
     */
    function updateBalance(address _tokenAddress, uint256 _amount)
        external
        onlyRole(FACTORY_ROLE)
    {
        if (balancesMap[_tokenAddress] == 0)
            donatedTokens.push(_tokenAddress);
        balancesMap[_tokenAddress] += _amount;
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

    /**
     * @dev                   check if address is whitelisted
     * @return                boolean indicating status
     */
    function isWhitelisted(address _address) external view returns (bool) {
        if (whitelist.length() == 0) return true;
        return whitelist.contains(_address);
    }

    // -----------------------------------------------------------------
    // ACCESS CONTROLLED
    // -----------------------------------------------------------------

    /**
     * @dev             pause fund
     * @return          boolean indicating result of the operation
     */
    function pause() external onlyRole(OWNER_ROLE) returns (bool) {
        if (status != Status.Open) revert NotAllowed();

        return _setStatus(Status.Paused);
    }

    /**
     * @dev             resume fund
     * @return          boolean indicating result of the operation
     */
    function resume() external onlyRole(OWNER_ROLE) returns (bool) {
        if (status != Status.Paused) revert NotAllowed();

        return _setStatus(Status.Open);
    }

    /**
     * @notice          this is final, a closed fund cannot be reopened
     * @dev             close fund
     * @return          boolean indicating result of the operation
     */
    function close() external onlyRole(OWNER_ROLE) returns (bool) {
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

    /**
     * @dev             batch set insertion
     * @param  _set     pointer to storage EnumerableSet
     * @param  _values  array of values to insert
     */
    function _batchSet(
        EnumerableSet.AddressSet storage _set,
        address[] memory _values
    ) internal {
        uint256 length = _values.length;
        uint256 i = 0;
        while (i < length) {
            _set.add(_values[i]);
            i++;
        }
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event StatusChange(uint256 indexed id);

    function getCheck(uint256 _index) public view returns (bytes32[2] memory) {
        return checks[_index];
    }

    function allChecks() public view returns (bytes32[2][] memory) {
        return checks;
    }

    function addCheck(bytes32[2] memory _check)
        public
        onlyRole(AUDITOR_ROLE)
        returns (bool)
    {
        checks.push(_check);

        return true;
    }

    function removeCheck(uint256 _index)
        public
        onlyRole(AUDITOR_ROLE)
        returns (bool)
    {
        if (checks.length <= 1) revert NoZeroChecks();

        _shiftPop(checks, _index);
        return true;
    }

    function _setChecks(bytes32[2][] memory _initialChecks) internal {
        checks = _initialChecks;
    }

    function _shiftPop(bytes32[2][] storage _array, uint256 _index) internal {
        require(_array.length > 0);
        require(_index <= _array.length - 1);

        _array[_index] = _array[_array.length - 1];
        _array.pop();
    }
}
