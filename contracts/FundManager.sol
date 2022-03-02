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

contract FundManager is Initializable, OwnableUpgradeable {
    struct Fund {
        bytes32 id;
        string name;
        address safeAddress;
        bool paused;
        bool closed;
    }

    mapping(bytes32 => Fund) private funds;

    // No constructors in upgradeable contracts.
    // see https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies#the-constructor-caveat
    //
    function initialize() public initializer {}

    /**
     * @dev             setup a new fund
     * @param id        unique identifier of the fund
     * @param name      name of the fund
     * @param owners    array of owner addresses for the fund
     */
    function setupFund(
        bytes32 id,
        string memory name,
        address[] memory owners
    ) external onlyOwner returns (string memory, address) {}

    /**
     * @dev             get fund by id
     * @param id        unique identifier of the fund
     */
    function getFund(bytes32 id)
        public
        view
        returns (
            string memory,
            address,
            bool,
            bool
        )
    {}

    /**
     * @dev             pause a fund
     * @param id        unique identifier of the fund
     */
    function pauseFund(bytes32 id) external onlyOwner returns (bool) {
        require(!funds[id].paused, "Fund is already paused.");
        require(!funds[id].closed, "Fund is closed.");
        funds[id].paused = true;
        return true;
    }

    /**
     * @dev             resume a fund
     * @param id        unique identifier of the fund
     */
    function resumeFund(bytes32 id) external onlyOwner returns (bool) {
        require(funds[id].paused, "Fund is not paused.");

        funds[id].paused = false;
        return true;
    }

    /**
     * @dev             close a fund
     * @param id        unique identifier of the fund
     */
    function closeFund(bytes32 id) external onlyOwner returns (bool) {
        require(!funds[id].closed, "Fund is already closed.");

        funds[id].closed = true;
        return true;
    }
}
