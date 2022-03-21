//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./libraries/Donations.sol";
import "./FundManager.sol";
import "./FundV1.sol";
import "./Registered.sol";
import "./SOS.sol";

import "hardhat/console.sol";

contract Donation is Registered, Ownable {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    Counters.Counter private donationIds;
    mapping(uint256 => Donations.Record) private donations;

    constructor(address _registry) {
        _setRegistry(_registry);
    }

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
        _depositToSafe(
            _getDepositAddress(_fundId, _tokenAddress),
            _amount,
            _tokenAddress
        );

        uint256 donationId = _recordDonation(_fundId, _tokenAddress, _amount);

        emit Donated(msg.sender, donationId, _fundId, _amount, _tokenAddress);

        _mint(msg.sender, donationId);

        return true;
    }

    function getRecord(uint256 _id)
        external
        view
        returns (Donations.Record memory)
    {
        return donations[_id];
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
            FundManager(_getAddress("FUND_MANAGER")).getDepositAddressFor(
                _fundId,
                _tokenAddress
            );
    }

    /**
     * @dev              donate to the fund
     * @param  _fundId   fund id
     * @param  _token    ERC20 address
     * @param  _amount   amount donated
     * @return           donation record id
     */
    function _recordDonation(
        uint256 _fundId,
        address _token,
        uint256 _amount
    ) internal returns (uint256) {
        donationIds.increment();

        uint256 donationId = donationIds.current();

        donations[donationId] = Donations.Record({
            donator: msg.sender,
            fundId: _fundId,
            amount: _amount,
            token: _token
        });

        return donationId;
    }

    /**
     * @dev                   transfer to safe
     * @param  _to            deposit address of the fund
     * @param  _amount        amount to donate
     * @param  _tokenAddress  ERC20 address
     */
    function _depositToSafe(
        address _to,
        uint256 _amount,
        address _tokenAddress
    ) internal {
        return IERC20(_tokenAddress).safeTransferFrom(msg.sender, _to, _amount);
    }

    /**
     * @dev                   mint an ERC721
     * @param  _recipient     address of the recipient
     * @param  _donationId    donation id
     * @return                id of the minted ERC721
     */
    function _mint(address _recipient, uint256 _donationId)
        internal
        returns (uint256)
    {
        return SOS(_getAddress("SOS")).mint(_recipient, _donationId);
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event Donated(
        address indexed donator,
        uint256 indexed donationId,
        uint256 indexed fundId,
        uint256 value,
        address tokenAddress
    );
}
