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

contract Governor is AccessControl, DynamicChecks, Registered, RequestManager {
    using SafeMath for uint256;

    error MissingRole(bytes32);
    error NotAllowedForFund(uint256);

    constructor(address _registry, bytes32[] memory _initialChecks)
        Registered(_registry)
        RequestManager(_initialChecks)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _getFund(uint256 _fundId) internal view returns (FundV1) {
        address fundAddress = FundManager(getAddress("FUND_MANAGER"))
            .getFundAddress(_fundId);

        return FundV1(fundAddress);
    }

    // -----------------------------------------------------------------
    // MODIFIERS
    // -----------------------------------------------------------------

    modifier onlyOpenFunds(uint256 _fundId) {
        FundV1 fund = _getFund(_fundId);
        if (!fund.isOpen()) revert NotAllowedForFund(_fundId);
        _;
    }

    modifier onlyFundRole(uint256 _fundId, bytes32 _role) {
        FundV1 fund = _getFund(_fundId);
        if (!fund.hasRole(_role, msg.sender)) revert MissingRole(_role);
        _;
    }
}
