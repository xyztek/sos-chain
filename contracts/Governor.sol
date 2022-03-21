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

    constructor(address _registry, bytes32[] memory _initialChecks)
        RequestManager(_initialChecks)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _register(_registry, "GOVERNOR");
    }

    function _getFund(uint256 _fundId) internal view returns (FundV1) {
        address fundAddress = FundManager(_getAddress("FUND_MANAGER"))
            .getFundAddress(_fundId);

        return FundV1(fundAddress);
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
