//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

library Checks {
    struct Check {
        bytes32 name;
        bool automated;
        bytes32 jobId;
    }
}
