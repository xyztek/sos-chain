// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract SVGComponents {
    using Strings for uint256;

    function colorToGridAnim(bytes[3] memory _colors)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                '<defs><linearGradient id="grad-anim" x1="0%" y1="0%" x2="100%" y2="100%">',
                stopTag(_colors, "0%"),
                stopTag([_colors[1], _colors[0], _colors[2]], "100%"),
                "</linearGradient></defs>"
            );
    }

    function stopTag(bytes[3] memory _colors, bytes memory _offset)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                '<stop offset="',
                _offset,
                '" stop-color="',
                _colors[0],
                '"><animate attributeName="stop-color" values="',
                _colors[0],
                ";",
                _colors[2],
                ";",
                _colors[1],
                ";",
                _colors[0],
                '" dur="7s" repeatCount="indefinite"/></stop>'
            );
    }

    function sideText(
        string memory _text,
        bytes memory _transform,
        bytes memory _anchor
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                '<text class="small" transform="',
                _transform,
                '" style="text-anchor:',
                _anchor,
                '" fill="#FFF">',
                _text,
                "</text>"
            );
    }

    function titleStack(
        uint256 _x,
        uint256 _y,
        bytes memory _sub,
        bytes memory _title
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                '<text class="title" transform="translate(',
                _x.toString(),
                ",",
                _y.toString(),
                ')"><tspan class="large" x="0">',
                _sub,
                '</tspan><tspan class="small alpha" x="0" dy="20">',
                _title,
                "</tspan></text>"
            );
    }
}
