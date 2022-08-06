//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FundManager is ERC1967Proxy, Ownable {
    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) ERC1967Proxy(_logic, _data) {
        _changeAdmin(_admin);
    }
}
