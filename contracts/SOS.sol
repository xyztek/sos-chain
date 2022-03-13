//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./FundManager.sol";
import "./FundV1.sol";
import "./NFTDescriptor.sol";
import "./Registered.sol";

import "hardhat/console.sol";

struct DonationRecord {
    uint256 fundId;
    uint256 amount;
    address tokenAddress;
}

contract SOS is AccessControl, ERC721, Registered {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;
    mapping(uint256 => DonationRecord) public metadata;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _registry, address _minterAddress)
        ERC721("SOS Chain", "SOS")
        Registered(_registry)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, _minterAddress);
    }

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        DonationRecord storage donation = metadata[_tokenId];

        address fundAddress = FundManager(getAddress("FUND_MANAGER"))
            .getFundAddress(donation.fundId);

        (
            string memory fundName,
            string memory fundFocus,
            string memory _fundDescription
        ) = FundV1(fundAddress).getMeta();

        NFTDescriptor descriptor = NFTDescriptor(getAddress("NFT_DESCRIPTOR"));

        address owner = ownerOf(_tokenId);

        string memory image = descriptor.encodeSVG(
            _tokenId,
            owner,
            donation.amount,
            donation.tokenAddress,
            fundName,
            fundFocus
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description": "SOS Chain Donation NFT", "image": "',
                            "data:image/svg+xml;base64,",
                            image,
                            '"}'
                        )
                    )
                )
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
        tokenIds.increment();

        uint256 tokenId = tokenIds.current();
        _mint(_recipient, tokenId);

        metadata[tokenId] = DonationRecord({
            fundId: _fundId,
            amount: _amount,
            tokenAddress: _tokenAddress
        });

        return tokenId;
    }
}
