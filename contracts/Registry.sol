//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract Registry is Ownable {
    mapping(bytes32 => address) private registry;

    function register(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(registry[_name] == address(0x0));

        registry[_name] = _address;

        return true;
    }

    function update(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(registry[_name] != address(0x0));

        registry[_name] = _address;

        return true;
    }

    function get(bytes32 _name) public view returns (address) {
        return registry[_name];
    }
}
