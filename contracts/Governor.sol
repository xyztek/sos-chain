//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./libraries/Geo.sol";

import "./FundV1.sol";
import "./FundManager.sol";
import "./DynamicChecks.sol";
import "./Registered.sol";
import "./RequestManager.sol";

contract Governor is AccessControl, DynamicChecks, Registered, RequestManager {
    using SafeMath for uint256;

    constructor(address _registry) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRegistry(_registry);
    }
}
