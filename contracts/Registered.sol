//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Registry.sol";

import "hardhat/console.sol";

contract Registered {
    Registry registry;

    constructor(address _registry) {
        registry = Registry(_registry);
    }

    // -----------------------------------------------------------------
    // INTERNAL API
    // -----------------------------------------------------------------

    /**
     * @dev           get and address from registry
     * @param  _name  registered name
     * @return        registered address
     */
    function getAddress(bytes32 _name) internal view returns (address) {
        return registry.get(_name);
    }

    /**
     * @dev           self register
     * @param  _name  name to register with
     * @return        boolean indicating op result
     */
    function _register(bytes32 _name) internal returns (bool) {
        return registry.register(_name, address(this));
    }
}
