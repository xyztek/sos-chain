// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SignedSafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/SVG.sol";
import "./libraries/HexStrings.sol";

import "./SVGConstants.sol";
import "./SVGComponents.sol";

contract NFTDescriptor is SVGConstants, SVGComponents {
    using Strings for uint256;
    using SafeMath for uint256;
    using SafeMath for uint160;
    using SafeMath for uint8;
    using SignedSafeMath for int256;
    using HexStrings for uint256;

    //uint256 constant sqrt10X128 = 1076067327063303206878105757264492625226;

    struct ConstructTokenURIParams {
        uint256 tokenId;
        address tokenAddress;
        string tokenSymbol;
        string fundName;
        string fundFocus;
        uint256 supportAmount;
        bool flipRatio;
        address gnosisSafeAddress;
        string organization;
        string cause;
    }

    function _constructTokenURI(
        uint256 _tokenId,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public pure returns (string memory) {
        return
            Base64.encode(
                _buildSVGBytes(
                    _tokenId,
                    _supportAmount,
                    _tokenAddress,
                    _fundName,
                    _fundFocus
                )
            );
    }

    function toSVG(
        uint256 _tokenId,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public pure returns (string memory) {
        return
            string(
                _buildSVGBytes(
                    _tokenId,
                    _supportAmount,
                    _tokenAddress,
                    _fundName,
                    _fundFocus
                )
            );
    }

    function _buildSVGBytes(
        uint256 _tokenId,
        uint256 _supportAmount,
        address _tokenAddress,
        string memory _fundName,
        string memory _fundFocus
    ) public pure returns (bytes memory) {
        string memory tokenColorA = tokenToColorHex(_tokenAddress, 0);
        string memory tokenColorB = tokenToColorHex(_tokenAddress, 136);

        string memory supportAsString = (_supportAmount / 1e18).toString();

        string memory staticLayer = string(
            abi.encodePacked(styleConstant, background(), logoConstant)
        );

        string memory dynamicLayer = string(
            abi.encodePacked(
                sideText(
                    _tokenId.toString(),
                    "rotate(90 132.5 142.5)",
                    "text-anchor:start"
                ),
                sideText(
                    addressToString(_tokenAddress),
                    "rotate(90 -107.5 382.5)",
                    "text-anchor:end"
                ),
                titleStack(20, 100, "Fund", _fundName),
                titleStack(20, 150, "Focus", _fundFocus),
                titleStack(20, 200, "Support", supportAsString),
                SVG.tag(
                    "rect",
                    string(
                        abi.encodePacked(
                            'x="235" y="480" width="10" height="10" ',
                            SVG.keyValue(
                                "fill",
                                string(abi.encodePacked("#", tokenColorA))
                            )
                        )
                    ),
                    ""
                ),
                SVG.tag(
                    "rect",
                    string(
                        abi.encodePacked(
                            'x="250" y="480" width="10" height="10" ',
                            SVG.keyValue(
                                "fill",
                                string(abi.encodePacked("#", tokenColorB))
                            )
                        )
                    ),
                    ""
                )
            )
        );

        return
            abi.encodePacked(
                '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg">',
                staticLayer,
                dynamicLayer,
                "</svg>"
            );
    }

    function constructTokenURI(ConstructTokenURIParams memory params)
        public
        pure
        returns (string memory)
    {
        string memory name = generateName(params);
        string memory _nftDescription = nftDescription(
            escapeQuotes(params.tokenSymbol),
            addressToString(params.gnosisSafeAddress)
        );
        string memory _nftDetails = nftDetails(
            params.tokenId.toString(),
            escapeQuotes(params.tokenSymbol),
            addressToString(params.tokenAddress)
        );
        //string memory image = Base64.encode(bytes(generateSVGImage(params)));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                _nftDescription,
                                _nftDetails,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                // image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function escapeQuotes(string memory symbol)
        internal
        pure
        returns (string memory)
    {
        bytes memory symbolBytes = bytes(symbol);
        uint8 quotesCount = 0;
        for (uint8 i = 0; i < symbolBytes.length; i++) {
            if (symbolBytes[i] == '"') {
                quotesCount++;
            }
        }
        if (quotesCount > 0) {
            bytes memory escapedBytes = new bytes(
                symbolBytes.length + (quotesCount)
            );
            uint256 index;
            for (uint8 i = 0; i < symbolBytes.length; i++) {
                if (symbolBytes[i] == '"') {
                    escapedBytes[index++] = "\\";
                }
                escapedBytes[index++] = symbolBytes[i];
            }
            return string(escapedBytes);
        }
        return symbol;
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

    function generateName(ConstructTokenURIParams memory params)
        private
        pure
        returns (string memory)
    {
        return
            string(
                abi.encodePacked("SOS - ", escapeQuotes(params.tokenSymbol))
            );
    }

    struct DecimalStringParams {
        // significant figures of decimal
        uint256 sigfigs;
        // length of decimal string
        uint8 bufferLength;
        // ending index for significant figures (funtion works backwards when copying sigfigs)
        uint8 sigfigIndex;
        // index of decimal place (0 if no decimal)
        uint8 decimalIndex;
        // start index for trailing/leading 0's for very small/large numbers
        uint8 zerosStartIndex;
        // end index for trailing/leading 0's for very small/large numbers
        uint8 zerosEndIndex;
        // true if decimal number is less than one
        bool isLessThanOne;
        // true if string should include "%"
        bool isPercent;
    }

    function generateDecimalString(DecimalStringParams memory params)
        private
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(params.bufferLength);
        if (params.isPercent) {
            buffer[buffer.length - 1] = "%";
        }
        if (params.isLessThanOne) {
            buffer[0] = "0";
            buffer[1] = ".";
        }

        // add leading/trailing 0's
        for (
            uint256 zerosCursor = params.zerosStartIndex;
            zerosCursor < params.zerosEndIndex.add(1);
            zerosCursor++
        ) {
            buffer[zerosCursor] = bytes1(uint8(48));
        }
        // add sigfigs
        while (params.sigfigs > 0) {
            if (
                params.decimalIndex > 0 &&
                params.sigfigIndex == params.decimalIndex
            ) {
                buffer[params.sigfigIndex--] = ".";
            }
            buffer[params.sigfigIndex--] = bytes1(
                uint8(uint256(48).add(params.sigfigs % 10))
            );
            params.sigfigs /= 10;
        }
        return string(buffer);
    }

    function sigfigsRounded(uint256 value, uint8 digits)
        private
        pure
        returns (uint256, bool)
    {
        bool extraDigit;
        if (digits > 5) {
            value = value.div((10**(digits - 5)));
        }
        bool roundUp = value % 10 > 4;
        value = value.div(10);
        if (roundUp) {
            value = value + 1;
        }
        // 99999 -> 100000 gives an extra sigfig
        if (value == 100000) {
            value /= 10;
            extraDigit = true;
        }
        return (value, extraDigit);
    }

    function abs(int256 x) private pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }

    function addressToString(address addr)
        internal
        pure
        returns (string memory)
    {
        return (uint256(uint160(addr))).toHexStringASCII(20);
    }

    function scale(
        uint256 n,
        uint256 inMn,
        uint256 inMx,
        uint256 outMn,
        uint256 outMx
    ) private pure returns (string memory) {
        return
            (n.sub(inMn).mul(outMx.sub(outMn)).div(inMx.sub(inMn)).add(outMn))
                .toString();
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
