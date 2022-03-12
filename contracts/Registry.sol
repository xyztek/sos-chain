//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

contract Registry is Ownable {
    error AlreadyRegistered();
    error NotFound();

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
        if (registry[_name] == address(0x0)) revert NotFound();

        return registry[_name];
    }

    /**
     * @dev              register contract address
     * @param _name      name of the contract
     * @param _address   address of the contract
     * @return           boolean indicating result of the operation
     */
    function register(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        if (registry[_name] != address(0)) revert AlreadyRegistered();

        registry[_name] = _address;
        contracts.push(_name);

        return true;
    }

    /**
     * @dev              update contract address
     * @param _name      name of the contract
     * @param _address   address of the contract
     * @return           boolean indicating result of the operation
     */
    function update(bytes32 _name, address _address)
        public
        onlyOwner
        returns (bool)
    {
        if (registry[_name] == address(0x0)) revert NotFound();

        registry[_name] = _address;

        return true;
    }
}
