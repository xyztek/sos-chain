//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "hardhat/console.sol";

interface Registry {
    function get(bytes32) external view returns (address);
}

interface FundManager {
    function getFundAddress(bytes32) external view returns (address);
}

interface Fund {
    function getDepositAddressFor(address) external view returns (address);
}

contract Deposit is Ownable {
    using SafeERC20 for IERC20;

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
        bytes32 _fundId,
        address _tokenAddress,
        uint256 _amount
    ) external returns (bool) {
        // HOW EXPENSIVE?
        address fundManagerAddress = registry.get("FUND_MANAGER");
        address fund = FundManager(fundManagerAddress).getFundAddress(_fundId);
        address depositAddress = Fund(fund).getDepositAddressFor(_tokenAddress);

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
        bytes32 indexed fundId,
        address indexed tokenAddress,
        uint256 value
    );
}
