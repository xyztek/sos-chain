//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./libraries/Donations.sol";
import "./Registered.sol";

contract DonationStorage is Registered, AccessControl {
    using Counters for Counters.Counter;
    bytes32 public constant STORE_ROLE = keccak256("STORE_ROLE");

    Counters.Counter private donationIds;
    mapping(uint256 => Donations.Record) private donations;

    constructor(address _registry) {
        _setRegistry(_registry);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(STORE_ROLE, address(0));
    }

    /**
     * @dev              record donation
     * @param  _donor    donor
     * @param  _fundId   fund id
     * @param  _token    ERC20 address
     * @param  _amount   amount donated
     * @return           donation record id
     */
    function recordDonation(
      address _donor,
      uint256 _fundId,
      address _token,
      uint256 _amount
    ) public onlyRole(STORE_ROLE) returns (uint256)  {
      return _recordDonation(_donor, _fundId, _token, _amount);
    }

    /**
     * @dev              record donation
     * @param  _donor    donor
     * @param  _fundId   fund id
     * @param  _token    ERC20 address
     * @param  _amount   amount donated
     * @return           donation record id
     */
    function _recordDonation(
      address _donor,
      uint256 _fundId,
      address _token,
      uint256 _amount
    ) internal returns (uint256) {
        donationIds.increment();

        uint256 donationId = donationIds.current();

        donations[donationId] = Donations.Record({
            donor: _donor,
            fundId: _fundId,
            amount: _amount,
            token: _token
        });

        emit Donated(_donor, donationId, _fundId, _amount, _token);

        return donationId;
    }

    function getRecord(uint256 _id)
        external
        view
        returns (Donations.Record memory)
    {
        return donations[_id];
    }

    // -----------------------------------------------------------------
    // EVENTS
    // -----------------------------------------------------------------

    event Donated(
        address indexed donor,
        uint256 indexed donationId,
        uint256 indexed fundId,
        uint256 value,
        address tokenAddress
    );
}
