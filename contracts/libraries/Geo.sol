//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

library Geo {
    uint256 private constant RESOLUTION = 1000000000000000;

    struct Coordinates {
        uint256 lat;
        uint256 lon;
    }

    function coordinatesFromPair(uint256[2] memory _pair)
        internal
        pure
        returns (Coordinates memory)
    {
        return Coordinates({lat: _pair[0], lon: _pair[1]});
    }
}
