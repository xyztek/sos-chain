pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BasicERC20 is ERC20 {
    constructor(uint256 initialBalance) public ERC20("Basic", "BSC") {
        _mint(msg.sender, initialBalance);
    }
}
