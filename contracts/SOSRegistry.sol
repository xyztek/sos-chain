//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract SOSRegistry is Ownable {
    using SafeMath for uint256;

    struct Record {
        address owner;
        address contractAddress;
        uint256 version;
    }

    mapping(bytes32 => Record) private registry;

    function register(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(registry[_name].contractAddress == address(0x0));

        Record memory record = Record({
            owner: msg.sender,
            contractAddress: _address,
            version: 1
        });

        registry[_name] = record;

        return true;
    }

    function update(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(registry[_name].contractAddress != address(0x0));

        registry[_name].contractAddress = _address;
        registry[_name].version = registry[_name].version.add(1);

        return true;
    }

    function get(bytes32 _name) public view returns (address, uint256) {
        return (registry[_name].contractAddress, registry[_name].version);
    }
}
