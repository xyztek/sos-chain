//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./FundManager.sol";
import "./FundV1.sol";
import "./Registry.sol";

import "hardhat/console.sol";

contract Gateway is Ownable, Registry {
    function getFundV1Meta(uint256 _id)
        external
        view
        returns (
            string memory,
            string memory,
            string memory,
            uint256
        )
    {
        FundV1(FundManager(get("FUND_MANAGER")).getFundAddress(_id)).getMeta();
    }
}
