//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "hardhat/console.sol";

contract DynamicChecks is AccessControl {
    error NoZeroChecks();
    error CheckAlreadyApproved();

    bytes32 public constant AUDIT_ROLE = keccak256("AUDIT_ROLE");
    bytes32[] internal checks;

    constructor(bytes32[] memory _initialChecks) {
        if (_initialChecks.length < 1) revert NoZeroChecks();
        checks = _initialChecks;
    }

    function getCheck(uint256 _index) public view returns (bytes32) {
        return checks[_index];
    }

    function allChecks() public view returns (bytes32[] memory) {
        return checks;
    }

    function addCheck(bytes32 _check)
        public
        onlyRole(AUDIT_ROLE)
        returns (bool)
    {
        checks.push(_check);

        return true;
    }

    function removeCheck(uint256 _index)
        public
        onlyRole(AUDIT_ROLE)
        returns (bool)
    {
        if (checks.length <= 1) revert NoZeroChecks();

        _shiftPop(checks, _index);
        return true;
    }

    function _shiftPop(bytes32[] storage _array, uint256 _index) internal {
        require(_array.length > 0);
        require(_index <= _array.length - 1);

        _array[_index] = _array[_array.length - 1];
        _array.pop();

        // TODO: ENSURE _array IS PASSED AS REFERENCE IN TESTS
    }

    modifier requireChecks() {
        if (checks.length < 1) revert NoZeroChecks();
        _;
    }
}
