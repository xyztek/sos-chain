//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./libraries/Donations.sol";
import "./DonationStorage.sol";
import "./FundManagerV1.sol";
import "./FundV1.sol";
import "./Registered.sol";
import "./SOS.sol";

contract Donation is Registered, Ownable {
    using SafeERC20 for IERC20;

    DonationStorage store;

    constructor(address _registry, address _storage) {
        _setRegistry(_registry);
        store = DonationStorage(_storage);
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
        require(_amount > 0, "amount must be greater than 0");

        _deposit(
            _getDepositAddress(_fundId, _tokenAddress),
            _amount,
            _tokenAddress
        );

        uint256 donationId = store.recordDonation(
          msg.sender,
          _fundId,
          _tokenAddress,
          _amount
        );

        FundManagerV1(_getAddress("FUND_MANAGER")).updateFundBalance(
          _fundId,
          _tokenAddress,
          _amount
        );

        _mint(msg.sender, donationId);

        return true;
    }

    function getRecord(uint256 _id)
        external
        view
        returns (Donations.Record memory)
    {
        return store.getRecord(_id);
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
            FundManagerV1(_getAddress("FUND_MANAGER")).getDepositAddressFor(
                _fundId,
                _tokenAddress
            );
    }

    /**
     * @dev                   transfer to safe
     * @param  _to            deposit address of the fund
     * @param  _amount        amount to donate
     * @param  _tokenAddress  ERC20 address
     */
    function _deposit(
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
}
