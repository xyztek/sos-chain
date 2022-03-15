//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

library Donations {
    struct Record {
        address donator;
        uint256 fundId;
        uint256 amount;
        address token;
    }
}
