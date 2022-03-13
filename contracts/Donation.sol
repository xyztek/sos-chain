//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./FundManager.sol";
import "./FundV1.sol";
import "./Registered.sol";
import "./SOS.sol";

import "hardhat/console.sol";

contract Donation is Registered, Ownable {
    using SafeERC20 for IERC20;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _registry) Registered(_registry) {}

    // -----------------------------------------------------------------
    // PUBLIC API
    // -----------------------------------------------------------------

    /**
     * @dev                   deposit into the safe
     * @param  _fundId        unique identifier of the fund to deposit into
     * @param  _tokenAddress  ERC20 address
     * @param  _amount        amount to deposit
     */
    function donate(
        uint256 _fundId,
        address _tokenAddress,
        uint256 _amount
    ) external returns (bool) {
        _donate(
            _fundId,
            _getDepositAddress(_fundId, _tokenAddress),
            _amount,
            _tokenAddress
        );

        _mint(msg.sender, _fundId, _amount, _tokenAddress);

        return true;
    }

    // -----------------------------------------------------------------
    // INTERNAL API
    // -----------------------------------------------------------------

    /**
     * @dev                   get address of the ERC721 minter contract
     * @param  _fundId        id of the fund
     * @param  _tokenAddress  ERC20 address
     * @return                contract address
     */
    function _getDepositAddress(uint256 _fundId, address _tokenAddress)
        internal
        view
        returns (address)
    {
        return
            FundManager(getAddress("FUND_MANAGER")).getDepositAddressFor(
                _fundId,
                _tokenAddress
            );
    }

    /**
     * @dev                   donate to the fund
     * @param  _fundId        fund id
     * @param  _to            deposit address of the fund
     * @param  _amount        amount to donate
     * @param  _tokenAddress  ERC20 address
     */
    function _donate(
        uint256 _fundId,
        address _to,
        uint256 _amount,
        address _tokenAddress
    ) internal {
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, _to, _amount);

        emit Donated(msg.sender, _fundId, _tokenAddress, _amount);
    }

    /**
     * @dev                   mint an ERC721
     * @param  _recipient     address of the recipient
     * @param  _fundId        fund id
     * @param  _amount        amount donated
     * @param  _tokenAddress  ERC20 address
     * @return                id of the minted ERC721
     */
    function _mint(
        address _recipient,
        uint256 _fundId,
        uint256 _amount,
        address _tokenAddress
    ) internal returns (uint256) {
        return
            SOS(getAddress("SOS")).mint(
                _recipient,
                _fundId,
                _amount,
                _tokenAddress
            );
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event Donated(
        address indexed from,
        uint256 indexed fundId,
        address indexed tokenAddress,
        uint256 value
    );
}
