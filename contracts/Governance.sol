//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import "hardhat/console.sol";

// UPGRADEABLE CONTRACT
// ----
// ! CANNOT CHANGE, when upgrading, the declaration ORDER or TYPE of STATES VARIABLES.
// ! CANNOT USE a constructor method.
// ! CANNOT USE initial values for variables (akin to constructor method).
// ----
// - CAN USE `initialize()` method instead of a constructor. Make sure to inherit from
//   Initializable and use initializer modifier on the `initialize()` method.
// - ENSURE to use `_Upgradeable` variants from @openzeppelin/contracts-upgradeable.

contract Governance is Initializable, OwnableUpgradeable {

}
