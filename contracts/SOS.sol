//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./FundManager.sol";
import "./Fund.sol";
import "./NFTDescriptor.sol";
import "./Registry.sol";

import "hardhat/console.sol";

struct Donation {
    uint256 fundId;
    uint256 amount;
    address tokenAddress;
}

contract SOS is ERC721, AccessControl {
    using Counters for Counters.Counter;

    Registry private registry;
    Counters.Counter private _tokenIds;
    mapping(uint256 => Donation) public metadata;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _registryAddress, address _minterAddress)
        ERC721("SOS Chain", "SOS")
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, _minterAddress);

        registry = Registry(_registryAddress);
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        Donation storage donation = metadata[_tokenId];

        address fundAddress = FundManager(registry.get("FUND_MANAGER"))
            .getFundAddress(donation.fundId);

        (string memory fundName, string memory fundFocus) = Fund(fundAddress)
            .getMeta();

        NFTDescriptor descriptor = NFTDescriptor(
            registry.get("NFT_DESCRIPTOR")
        );

        return
            descriptor.constructTokenURI(
                _tokenId,
                donation.amount,
                donation.tokenAddress,
                fundName,
                fundFocus
            );
    }

    // -----------------------------------------------------------------
    // ADMIN API
    // -----------------------------------------------------------------

    /**
     * @dev                   mint an nft
     * @param  _recipient     address of the recipient
     * @param  _fundId        id of the fund
     * @param  _amount        amount deposited
     * @param  _tokenAddress  tracked address of the deposited token
     * @return                id of the minted ERC721
     */
    function mint(
        address _recipient,
        uint256 _fundId,
        uint256 _amount,
        address _tokenAddress
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        _tokenIds.increment();

        uint256 tokenId = _tokenIds.current();
        _mint(_recipient, tokenId);

        metadata[tokenId] = Donation({
            fundId: _fundId,
            amount: _amount,
            tokenAddress: _tokenAddress
        });

        return tokenId;
    }
}
