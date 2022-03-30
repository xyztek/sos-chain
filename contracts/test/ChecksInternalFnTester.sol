//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {Checks} from "../libraries/Checks.sol";

contract ChecksInternalFnTester {
    function isAutomated(bytes32[2] memory _check) public pure returns (bool) {
        return Checks.isAutomated(_check);
    }
}
