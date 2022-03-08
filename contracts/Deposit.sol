//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "hardhat/console.sol";

import "./Registry.sol";
import "./FundManager.sol";

contract Deposit is Ownable {
    using SafeERC20 for IERC20;
    error AllowanceIsNotRegistered();

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
     * @param  _tokenAddress  token symbol (must be an allowed token)
     * @param  _amount        amount to deposit
     */
    function deposit(
        string memory _fundId,
        address _tokenAddress,
        uint256 _amount
    ) external payable returns (bool) {
        // HOW EXPENSIVE?
        if (
            IERC20(_tokenAddress).allowance(msg.sender, address(this)) >=
            _amount
        ) {
            revert AllowanceIsNotRegistered();
        }

        address fundManagerAddress = registry.get("FUND_MANAGER");
        address depositAddress = FundManager(fundManagerAddress)
            .getDepositAddressFor(_fundId, _tokenAddress);

        IERC20(_tokenAddress).safeTransferFrom(
            msg.sender,
            depositAddress,
            _amount
        );

        emit Support(msg.sender, _fundId, _tokenAddress, _amount);

        // TODO mint ERC721

        return true;
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event Support(
        address indexed from,
        string indexed fundId,
        address indexed tokenAddress,
        uint256 value
    );
}
