// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

library SVG {
    using Strings for uint256;

    function tag(
        bytes memory _name,
        bytes memory _attributes,
        bytes memory _contents
    ) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                "<",
                _name,
                " ",
                _attributes,
                ">",
                _contents,
                "</",
                _name,
                ">"
            );
    }

    function toRGBA(
        string memory r,
        string memory b,
        string memory g,
        string memory a
    ) public pure returns (bytes memory) {
        return abi.encodePacked("rgba(", r, ",", b, ",", g, ",", a, ")");
    }

    function keyValue(bytes memory _key, bytes memory _value)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(_key, "=", '"', _value, '"');
    }

    function toPixelValue(uint256 value) public pure returns (bytes memory) {
        return abi.encodePacked(value.toString(), "px");
    }

    function rPad(bytes memory str) public pure returns (bytes memory) {
        return abi.encodePacked(str, " ");
    }
}
