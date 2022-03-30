//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {Checks} from "./libraries/Checks.sol";

import "hardhat/console.sol";

contract DynamicChecks is AccessControl {
    error NoZeroChecks();
    error Forbidden();

    bytes32 public constant AUDIT_ROLE = keccak256("AUDIT_ROLE");
    bytes32[2][] internal checks;

    function getCheck(uint256 _index) public view returns (bytes32[2] memory) {
        return checks[_index];
    }

    function allChecks() public view returns (bytes32[2][] memory) {
        return checks;
    }

    function addCheck(bytes32[2] memory _check)
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

    function _setChecks(bytes32[2][] memory _initialChecks) internal {
        checks = _initialChecks;
    }

    function _shiftPop(bytes32[2][] storage _array, uint256 _index) internal {
        require(_array.length > 0);
        require(_index <= _array.length - 1);

        _array[_index] = _array[_array.length - 1];
        _array.pop();

        // TODO: ENSURE _array IS PASSED AS REFERENCE IN TESTS
    }
}
