//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./Fund.sol";
import "./FundManager.sol";
import "./Registry.sol";

import "hardhat/console.sol";

import "./Registry.sol";
import "./FundManager.sol";

contract Deposit is Ownable {
    using SafeERC20 for IERC20;
    error AllowanceIsNotRegistered();

    Counters.Counter private _tokenIds;
    Registry private registry;

    constructor(address _registryAddress) ERC721("SOS chain token", "SOS") {
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
    ) external returns (bool) {
        // HOW EXPENSIVE?

        if (
            IERC20(_tokenAddress).allowance(msg.sender, address(this)) < _amount
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
    // INTERNAL API
    // -----------------------------------------------------------------

    /**
     * @dev                 mint an nft for an address
     * @param recipient     recipient address for the nft
     * @param tokenURI      token uri of the hashed attributes of the nft
     */
    function mintNFT(address recipient, string memory tokenURI)
        internal
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
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
