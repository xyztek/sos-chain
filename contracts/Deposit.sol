//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "hardhat/console.sol";

interface FundManager {
    function getFund(bytes32 id)
        external
        view
        returns (
            string memory,
            address,
            bool,
            bool
        );
}

contract Deposit is Ownable {
    using SafeERC20 for IERC20;

    address private fundManagerAddress;

    mapping(bytes32 => address) public allowedTokens;

    event Support(
        address indexed from,
        bytes32 indexed fundId,
        address indexed tokenAddress,
        uint256 value
    );

    function initialize(address _fundManagerAddress) public {
        fundManagerAddress = _fundManagerAddress;
    }

    /**
     * @dev             deposit into the safe
     * @param fundId    unique identifier of the fund to deposit into
     * @param symbol    token symbol (must be an allowed token)
     * @param amount    amount to deposit
     */
    function deposit(
        bytes32 fundId,
        bytes32 symbol,
        uint256 amount
    ) external returns (bool) {
        require(allowedTokens[symbol] != address(0x0), "Token not accepted.");

        (
            string memory fundName,
            address fundAddress,
            bool paused,
            bool closed
        ) = FundManager(fundManagerAddress).getFund(fundId);

        require(!paused, "Fund is paused.");
        require(!closed, "Fund is closed.");

        address tokenAddress = allowedTokens[symbol];

        IERC20(tokenAddress).safeTransferFrom(msg.sender, fundAddress, amount);

        emit Support(msg.sender, fundId, tokenAddress, amount);

        // TODO mint ERC721

        return true;
    }

    // Functions to update the list of tokens supported for deposit

    /**
     * @dev             add a token to the list of allowed tokens
     * @param symbol    token symbol
     * @param _address  token contract address
     */
    function addToken(bytes32 symbol, address _address)
        public
        onlyOwner
        returns (bool)
    {
        allowedTokens[symbol] = _address;

        return true;
    }

    /**
     * @dev             remove a token from the list of allowed tokens
     * @param symbol    token symbol
     */
    function removeToken(bytes32 symbol) public onlyOwner returns (bool) {
        require(allowedTokens[symbol] != address(0x0));

        delete (allowedTokens[symbol]);

        return true;
    }
}
