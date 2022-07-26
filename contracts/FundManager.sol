//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "hardhat/console.sol";



import "./Registered.sol";



contract FundManager is ERC1967Proxy, Registered {

constructor(address _logic, address _admin ,bytes memory _data) ERC1967Proxy(_logic, _data) {

        console.log("2------->", _logic);
        _changeAdmin(_admin);

        //(address _registry,) = abi.decode(_data, (address,address));
        // ;
}

}