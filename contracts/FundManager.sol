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
        bool isPaused;
        bool isClosed;
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
     * @param owners    array of owners for the fund
     */
    function setupFund(
        bytes id,
        string name,
        address[] owners
    ) external onlyOwner returns (string, address) {}

    /**
     * @dev             get fund by id
     * @param id        unique identifier of the fund
     */
    function getFund(bytes id)
        public
        view
        returns (
            string,
            address,
            bool,
            bool
        )
    {}

    /**
     * @dev             pause a fund
     * @param id        unique identifier of the fund
     */
    function pauseFund(bytes id) external onlyOwner returns (bool) {}

    /**
     * @dev             resume a fund
     * @param id        unique identifier of the fund
     */
    function resumeFund(bytes id) external onlyOwner returns (bool) {}

    /**
     * @dev             close a fund
     * @param id        unique identifier of the fund
     */
    function closeFund(bytes id) external onlyOwner returns (bool) {}
}
