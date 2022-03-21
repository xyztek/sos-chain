//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Registry.sol";

import "hardhat/console.sol";

contract Registered {
    Registry registry;

    // -----------------------------------------------------------------
    // INTERNAL API
    // -----------------------------------------------------------------

    /**
     * @dev           get an address from registry
     * @param  _name  registered name
     * @return        registered address
     */
    function _getAddress(bytes32 _name) internal view returns (address) {
        return registry.get(_name);
    }

    /**
     * @dev           self register
     * @param  _name  name to register with
     * @return        boolean indicating op result
     */
    function _register(address _registry, bytes32 _name)
        internal
        returns (bool)
    {
        registry = Registry(_registry);
        return registry.register(_name, address(this));
    }
}
