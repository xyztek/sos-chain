//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./Fund.sol";
import "./FundManager.sol";
import "./Registry.sol";
import "./SOS.sol";

import "hardhat/console.sol";

contract Deposit is Ownable {
    using SafeERC20 for IERC20;
    error InsufficientAllowance();

    Counters.Counter private _tokenIds;
    Registry private registry;

    constructor(address _registryAddress) {
        registry = Registry(_registryAddress);
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev                   deposit into the safe
     * @param  _fundId        unique identifier of the fund to deposit into
     * @param  _tokenAddress  ERC20 address
     * @param  _amount        amount to deposit
     */
    function deposit(
        uint256 _fundId,
        address _tokenAddress,
        uint256 _amount
    ) external returns (bool) {
        _donate(
            _fundId,
            _getDepositAddress(_fundId, _tokenAddress),
            _amount,
            _tokenAddress
        );

        _mint(msg.sender, _fundId, _amount, _tokenAddress);

        return true;
    }

    // -----------------------------------------------------------------
    // INTERNAL API
    // -----------------------------------------------------------------

    /**
     * @dev                   check ERC20 allowance()
     * @param  _tokenAddress  ERC20 address
     * @return                contract address
     */
    function _allowance(address _tokenAddress) internal view returns (uint256) {
        return IERC20(_tokenAddress).allowance(msg.sender, address(this));
    }

    /**
     * @dev                   get address of the ERC721 minter contract
     * @return                contract address
     */
    function _getMinter() internal view returns (SOS) {
        return SOS(registry.get("SOS"));
    }

    /**
     * @dev                   get address of the ERC721 minter contract
     * @param  _fundId        id of the fund
     * @param  _tokenAddress  ERC20 address
     * @return                contract address
     */
    function _getDepositAddress(uint256 _fundId, address _tokenAddress)
        internal
        view
        returns (address)
    {
        address fundManagerAddress = registry.get("FUND_MANAGER");

        return
            FundManager(fundManagerAddress).getDepositAddressFor(
                _fundId,
                _tokenAddress
            );
    }

    /**
     * @dev                   donate to the fund
     * @param  _fundId        fund id
     * @param  _to            deposit address of the fund
     * @param  _amount        amount to donate
     * @param  _tokenAddress  ERC20 address
     */
    function _donate(
        uint256 _fundId,
        address _to,
        uint256 _amount,
        address _tokenAddress
    ) internal {
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, _to, _amount);

        emit Donate(msg.sender, _fundId, _tokenAddress, _amount);
    }

    /**
     * @dev                   mint an ERC721
     * @param  _recipient     address of the recipient
     * @param  _fundId        fund id
     * @param  _amount        amount donated
     * @param  _tokenAddress  ERC20 address
     * @return                id of the minted ERC721
     */
    function _mint(
        address _recipient,
        uint256 _fundId,
        uint256 _amount,
        address _tokenAddress
    ) internal returns (uint256) {
        SOS minter = _getMinter();
        return minter.mint(_recipient, _fundId, _amount, _tokenAddress);
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event Donate(
        address indexed from,
        uint256 indexed fundId,
        address indexed tokenAddress,
        uint256 value
    );
}
