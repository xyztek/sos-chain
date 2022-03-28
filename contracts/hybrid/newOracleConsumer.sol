// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "../Registry.sol";
import "../Governor.sol";
import "../Registered.sol";
import "hardhat/console.sol";

contract OracleConsumer is ChainlinkClient, ConfirmedOwner, Registered {
    using Chainlink for Chainlink.Request;

    uint256 private fee;

    address private oracle;
    string private jobId;

    event RequestFullfiled(
        bytes32 indexed _requestId,
        uint256 indexed _govRequestId,
        bytes32 indexed _checkId,
        bool _success
    );

    function setOracle(address _oracle) public onlyOwner {
        oracle = _oracle;
    }

    function setJob(string memory _job) public onlyOwner {
        jobId = _job;
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    constructor(
        address _oracle,
        string memory _jobId,
        uint256 _fee,
        address _registry
    ) ConfirmedOwner(msg.sender) {
        setPublicChainlinkToken();
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;

        _setRegistry(_registry);
    }

    function tryApprove(bytes32 _jobId, bytes memory _params)
        public
        onlyOwner
        returns (bytes32)
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            _jobId,
            address(this),
            this.approveCheck.selector
        );
        req.addBytes("params", _params);

        return sendChainlinkRequestTo(oracle, req, fee);
    }

    function approveCheck(
        bytes32 _requestId, //oracle
        bytes32 _data,
        bytes32 _checkId,
        uint256 _govRequestId
    ) public recordChainlinkFulfillment(_requestId) {
        bool success = bytes32("2") == _data;

        Governor(_getAddress("GOVERNOR")).approveCheck(
            _govRequestId,
            _checkId,
            success
        );

        emit RequestFullfiled(_requestId, _govRequestId, _checkId, success);
        //hit approve check  requestManager   function approveCheck(uint256 _id, bytes32 _check , bool data) public returns (bool) {
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(
            _requestId,
            _payment,
            _callbackFunctionId,
            _expiration
        );
    }

    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
