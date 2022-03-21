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

import "hardhat/console.sol";

error MissingRole(bytes32);

contract Governor is AccessControl, DynamicChecks, Registered, RequestManager {
    using SafeMath for uint256;

    constructor(address _registry)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRegistry(_registry);
    }

    // -----------------------------------------------------------------
    // MODIFIERS
    // -----------------------------------------------------------------

    modifier onlyOpenFunds(uint256 _fundId) {
        FundV1 fund = _getFund(_fundId);
        if (!fund.isOpen()) revert NotAllowed();
        _;
    }

    modifier onlyFundRole(uint256 _fundId, bytes32 _role) {
        FundV1 fund = _getFund(_fundId);
        if (!fund.hasRole(_role, msg.sender)) revert MissingRole(_role);
        _;
    }
}
