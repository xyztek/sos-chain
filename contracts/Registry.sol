//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract Registry is Ownable {
    bytes32[] private contracts;
    mapping(bytes32 => address) private registry;

    /**
     * @dev              get a list of registered contract names
     * @return           a list of registered contract names
     */
    function registered() public view returns (bytes32[] memory) {
        return contracts;
    }

    /**
     * @dev              get contract address
     * @param _name      name of the contract
     * @return           address of the queried contract
     */
    function get(bytes32 _name) public view returns (address) {
        return registry[_name];
    }

    /**
     * @dev              register contract address in the registry
     * @param _name      name of the contract
     * @param _address   address of the contract
     * @return           boolean indicating result of the operation
     */
    function register(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(registry[_name] == address(0x0));

        registry[_name] = _address;
        contracts.push(_name);

        return true;
    }

    /**
     * @dev              update contract address in the registry
     * @param _name      name of the contract
     * @param _address   address of the contract
     * @return           boolean indicating result of the operation
     */
    function update(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        require(registry[_name] != address(0x0));

        registry[_name] = _address;

        return true;
    }
}
