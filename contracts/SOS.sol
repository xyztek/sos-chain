//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./libraries/Donations.sol";
import "./Donation.sol";
import "./FundManager.sol";
import "./FundV1.sol";
import "./NFTDescriptor.sol";
import "./Registered.sol";

import "hardhat/console.sol";

contract SOS is AccessControl, ERC721, Registered {
    using Counters for Counters.Counter;

    Counters.Counter private tokenIds;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    mapping(uint256 => uint256) public donations;

    constructor(address _registry, address _minterAddress)
        ERC721("SOS Chain", "SOS")
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, _minterAddress);

        _setRegistry(_registry);
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

    function SVG(uint256 _tokenId) public view returns (string memory) {
        Donations.Record memory record = _getDonationRecord(_tokenId);

        (string memory fundName, string memory fundFocus) = _getFundMeta(
            record.fundId
        );

        NFTDescriptor descriptor = NFTDescriptor(_getAddress("NFT_DESCRIPTOR"));

        address owner = ownerOf(_tokenId);

        return
            descriptor.buildSVG(
                _tokenId,
                owner,
                record.amount,
                record.token,
                fundName,
                fundFocus
            );
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        Donations.Record memory record = _getDonationRecord(_tokenId);

        (string memory fundName, string memory fundFocus) = _getFundMeta(
            record.fundId
        );

        NFTDescriptor descriptor = NFTDescriptor(_getAddress("NFT_DESCRIPTOR"));

        address owner = ownerOf(_tokenId);

        string memory image = descriptor.encodeSVG(
            _tokenId,
            owner,
            record.amount,
            record.token,
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
    // ADMIN
    // -----------------------------------------------------------------

    /**
     * @dev                 mint an nft
     * @param  _recipient   recipient address
     * @param  _donationId  donation ID
     * @return              id of the minted ERC721
     */
    function mint(address _recipient, uint256 _donationId)
        public
        onlyRole(MINTER_ROLE)
        returns (uint256)
    {
        tokenIds.increment();

        uint256 tokenId = tokenIds.current();

        _mint(_recipient, tokenId);

        donations[tokenId] = _donationId;

        return tokenId;
    }

    function _getDonationRecord(uint256 _tokenId)
        internal
        view
        returns (Donations.Record memory)
    {
        uint256 donationId = donations[_tokenId];
        return Donation(_getAddress("DONATION")).getRecord(donationId);
    }

    function _getFundMeta(uint256 _fundId)
        internal
        view
        returns (string memory, string memory)
    {
        return FundManager(_getAddress("FUND_MANAGER")).getFundMeta(_fundId);
    }
}
