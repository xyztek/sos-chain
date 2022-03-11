// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./libraries/HexStrings.sol";

import "./SVGConstants.sol";
import "./SVGComponents.sol";


contract NFTDescriptor is SVGConstants, SVGComponents {
    using Strings for uint256;
    using HexStrings for uint256;

    function constructTokenURI(
        uint256 _tokenId,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public view returns (string memory) {
        return
            Base64.encode(
                _buildSVG(
                    _tokenId,
                    _supportAmount,
                    _tokenAddress,
                    _fundName,
                    _fundFocus
                )
            );
    }

    function buildSVG(
        uint256 _tokenId,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public view returns (string memory) {
        return
            string(
                _buildSVG(
                    _tokenId,
                    _supportAmount,
                    _tokenAddress,
                    _fundName,
                    _fundFocus
                )
            );
    }

    function _buildSVG(
        uint256 _tokenId,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public view returns (bytes memory) {
        string memory tokenColorA = tokenToColorHex(_tokenAddress, 77);
        string memory tokenColorB = tokenToColorHex(_tokenAddress, 136);

        bytes memory supportAsBytes = abi.encodePacked(
            (_supportAmount / 10**18).toString()// USE ERC20(_tokenAddress).decimals() insted of 18
        );

        bytes memory staticLayer = abi.encodePacked(
            styleConstant,
            background(),
            logoConstant
        );

        bytes memory dynamicLayer = abi.encodePacked(
            sideText(
                abi.encodePacked(_tokenId.toString()),
                abi.encodePacked("rotate(90 132.5 142.5)"),
                abi.encodePacked("text-anchor:start"),
                abi.encodePacked("small"),
                abi.encodePacked("#FFF")
            ),
            sideText(
                addressToBytes(_tokenAddress),
                abi.encodePacked("rotate(90 -107.5 382.5)"),
                abi.encodePacked("text-anchor:end"),
                abi.encodePacked("small"),
                abi.encodePacked("#FFF")
            ),
            titleStack(30, 110, "Fund", abi.encodePacked(_fundName)),
            titleStack(30, 180, "Focus", abi.encodePacked(_fundFocus)),
            titleStackTokenSymbol(30, 250, "Donation", supportAsBytes, abi.encodePacked("USDC")),//use ERC20(_tokenAddress).symbol() instead of usdc
            colorToGridAnim(tokenColorA,tokenColorB),
            animRect,
            pathConstant,
            animCircle1,
            animCircle2
        );

        return
            abi.encodePacked(
                '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg">',
                staticLayer,
                dynamicLayer,
                "</svg>"
            );
    }

    function nftDescription(
        string memory tokenSymbol,
        string memory gnosisSafeAddress
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "This NFT represents a donation to a SOS chain ",
                    tokenSymbol,
                    "The owner of this NFT has voting rights for an SOS chain.\\n",
                    "\\Safe Address: ",
                    gnosisSafeAddress
                )
            );
    }

    function nftDetails(
        string memory tokenId,
        string memory tokenSymbol,
        string memory tokenAddress
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    " Address: ",
                    tokenAddress,
                    "\\nSymbol: ",
                    tokenSymbol,
                    "\\nToken ID: ",
                    tokenId,
                    "\\n"
                )
            );
    }

    function addressToString(address _address)
        internal
        pure
        returns (string memory)
    {
        return (uint256(uint160(_address))).toHexStringASCII(20);
    }

    function addressToBytes(address _address)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(addressToString(_address));
    }

    function tokenToColorHex(address token, uint256 offset)
        internal
        pure
        returns (string memory str)
    {
        return
            string(
                (uint256(uint160(token)) >> offset).toHexStringASCIINoPrefix(3)
            );
    }
}
