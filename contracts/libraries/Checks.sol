//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

library Checks {
    function isAutomated(bytes32[2] memory _check)
        internal
        pure
        returns (bool)
    {
        return _check[1] != "";
    }
}
