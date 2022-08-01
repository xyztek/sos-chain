//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "hardhat/console.sol";

contract FundManager is ERC1967Proxy{

   
    constructor(address _logic, bytes memory _data) 
    ERC1967Proxy(_logic, _data) {
        _changeAdmin(msg.sender);
    }

    function getImplementation() external {
        return ERC1967Proxy._implementation();}
}
