// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

library SVG {
    using Strings for uint256;

    function tag(
        string memory _name,
        string memory _attributes,
        string memory _contents
    ) public pure returns (string memory) {
        return
            string(
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
                )
            );
    }

    function toRGBA(
        string memory r,
        string memory b,
        string memory g,
        string memory a
    ) public pure returns (string memory) {
        return
            string(abi.encodePacked("rgba(", r, ",", b, ",", g, ",", a, ")"));
    }

    function keyValue(string memory _key, string memory _value)
        public
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(_key, "=", '"', _value, '"'));
    }

    function toPixelValue(uint256 value) public pure returns (string memory) {
        return string(abi.encodePacked(value.toString(), "px"));
    }

    function rPad(string memory str) public pure returns (string memory) {
        return string(abi.encodePacked(str, " "));
    }
}
