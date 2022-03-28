// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

import "hardhat/console.sol";

contract OracleConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 private fee;
    bytes32 public responseBytes;

    address private oracle;
    string private jobId;

    event RequestBytesFullfiled(
        bytes32 indexed requestId,
        bytes32 indexed response
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
        uint256 _fee
    ) ConfirmedOwner(msg.sender) {
        setPublicChainlinkToken();
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }

    function requestBytes(int256 x, int256 y) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(jobId),
            address(this),
            this.fulfillBytes.selector
        );
        req.addInt("x", x);
        req.addInt("y", y);
        sendChainlinkRequestTo(oracle, req, fee);
        responseBytes = 0x3900000000000000000000000000000000000000000000000000000000000000;
    }

    function approveCheck(
        bytes32 _requestId,
        bytes32 calldata _data,
        bytes32 _fundId
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestBytesFullfiled(_requestId, data);
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
