//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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
}
