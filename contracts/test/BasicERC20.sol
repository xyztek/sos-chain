pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BasicERC20 is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialBalance
    ) public ERC20(_name, _symbol) {
        _mint(msg.sender, _initialBalance);
    }
}