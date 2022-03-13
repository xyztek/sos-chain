//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BasicToken is ERC20 {
    /*constructor(uint256 initialBalance) ERC20("Basic", "BSC") public {
      _mint(msg.sender, initialBalance); }*/

      constructor(string memory name, string memory symbol, uint256 initialBalance) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        _mint(msg.sender, initialBalance * 10**uint(decimals()));
    }

    function getTokenAddress() public view returns (address) {
        return
            address(this);
    }
}