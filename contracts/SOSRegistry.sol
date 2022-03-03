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

    mapping(string => Record) private registry;

    function register(string memory _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(registry[_name].contractAddress != address(0x0));

        Record memory record = Record({
            owner: msg.sender,
            contractAddress: _address,
            version: 1
        });

        registry[_name] = record;

        return true;
    }

    function update(string memory _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        Record memory record = registry[_name];

        require(record.owner == msg.sender);

        record.contractAddress = _address;
        record.version = record.version.add(1);

        registry[_name] = record;

        return true;
    }

    function get(string memory _name) public view returns (address, uint256) {
        Record memory record = registry[_name];

        return (record.contractAddress, record.version);
    }
}
