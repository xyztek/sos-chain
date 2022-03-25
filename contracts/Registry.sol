//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

error NotFound();

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
        if (registry[_name] == address(0x0)) revert NotFound();

        return registry[_name];
    }

    /**
     * @dev              get contract address
     * @param _names     name of the contract
     * @return           addresses of the queried contracts
     */
    function batchGet(bytes32[] memory _names) public view returns (address[] memory){
        uint256 length = _names.length;
        address[] memory addresses = new address[](length);

        for(uint256 i = 0; i< length; i++){
            addresses[i] = get(_names[i]);
        }
        return addresses;
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
        if (registry[_name] != address(0)) return true;

        registry[_name] = _address;
        contracts.push(_name);

        return true;
    }

    /**
     * @dev              register contract addresses
     * @param _name      array of name of contracts
     * @param _address   address arrays of contracts
     * @return           boolean indicating result of the operation
     */
    function batchRegister(bytes32[] memory _name, address[] memory _address) 
        public 
        onlyOwner 
        returns (bool)
    {
        uint256 length = _name.length;
        for(uint256 i = 0; i< length; i++){
            if (registry[_name[i]] != address(0)) continue;
            registry[_name[i]] = _address[i];
            contracts.push(_name[i]);
        }
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

    /**
     * @dev              update contracts' addresses
     * @param _name      array of name of contracts
     * @param _address   address arrays of contracts
     * @return           boolean indicating result of the operation
     */
    function batchUpdate(bytes32[] memory _name, address[] memory _address)
        public
        onlyOwner
        returns (bool)
    {
        uint256 length = _name.length;
        for(uint256 i = 0; i< length; i++){
            if (registry[_name[i]] == address(0x0)) continue;
            registry[_name[i]] = _address[i];
        }
        return true;
    }
}
