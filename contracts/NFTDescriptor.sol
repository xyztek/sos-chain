// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./libraries/HexStrings.sol";

import "./SVGConstants.sol";
import "./SVGComponents.sol";


contract NFTDescriptor is SVGConstants, SVGComponents {
    using SafeMath for uint256;
    using Strings for uint256;
    using HexStrings for uint256;
    using Strings for uint256;

    function amountFormatter(uint256 fixValue, uint256 decimalAmount, uint256 amount
    ) public view returns (string memory) {
        string memory left = (amount / ( 10 ** decimalAmount)).toString();
        string memory right = ((amount / (10 ** (decimalAmount - fixValue))) % (10 ** (fixValue - 1))).toString();
        uint256 length = fixValue - bytes(string(right)).length;
        if(length == 4) return string(left);
        for(uint i = 0; i < length; i++){
            right = string(abi.encodePacked("0", right));
        }
        return string(abi.encodePacked(left, ".", right));
    }

    function encodeSVG(
        uint256 _tokenId,
        address _ownerAddress,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public view returns (string memory) {
        return
            Base64.encode(
                _buildSVG(
                    _tokenId,
                    _ownerAddress,
                    _supportAmount,
                    _tokenAddress,
                    _fundName,
                    _fundFocus
                )
            );
    }

    function buildSVG(
        uint256 _tokenId,
        address _ownerAddress,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public view returns (string memory) {
        return
            string(
                _buildSVG(
                    _tokenId,
                    _ownerAddress,
                    _supportAmount,
                    _tokenAddress,
                    _fundName,
                    _fundFocus
                )
            );
    }

    function _buildSVG(
        uint256 _tokenId,
        address _ownerAddress,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public view returns (bytes memory) {
        bytes[3] memory colors = [
            tokenToColorHex(_ownerAddress, 3),
            tokenToColorHex(_ownerAddress, 57),
            tokenToColorHex(_ownerAddress, 122)
        ];
       
        string memory supportAmount = amountFormatter(5, ERC20(_tokenAddress).decimals(), _supportAmount);

        bytes memory dynamicLayer = abi.encodePacked(
            sideText(_tokenId.toString(), "rotate(90 132.5 142.5)", "start"),
            sideText(
                addressToString(_ownerAddress),
                "rotate(90 -107.5 382.5)",
                "end"
            ),
            titleStack(30, 110, "Fund", abi.encodePacked(_fundName)),
            titleStack(30, 180, "Focus", abi.encodePacked(_fundFocus)),
            titleStack(
                30,
                250,
                "Donation",
                abi.encodePacked(
                    supportAmount,
                    " ",
                    ERC20(_tokenAddress).symbol()
                )
            ),
            colorToGridAnim(colors)
        );

        return
            abi.encodePacked(
                '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg">',
                styleConstant,
                shapes,
                logoConstant,
                dynamicLayer,
                "</svg>"
            );
    }

    function addressToString(address _address)
        internal
        pure
        returns (string memory)
    {
        return (uint256(uint160(_address))).toHexStringASCII(20);
    }

    function tokenToColorHex(address token, uint256 offset)
        internal
        pure
        returns (bytes memory str)
    {
        return
            abi.encodePacked(
                "#",
                (uint256(uint160(token)) >> offset).toHexStringASCIINoPrefix(3)
            );
    }
}
