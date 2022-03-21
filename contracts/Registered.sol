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
     * @dev               set registry
     * @param  _registry  registry address
     */
    function _setRegistry(address _registry) internal {
        registry = Registry(_registry);
    }
}
