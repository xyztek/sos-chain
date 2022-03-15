// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract OracleConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 private fee;
    int256 public responseInt;
    bytes32 public responseBytes;

    address private oracle;
    string private jobId;

    event RequestBytesFullfiled(
        bytes32 indexed requestId,
        bytes32 indexed response
    );

    event RequestIntFullfiled(
        bytes32 indexed requestId,
        int256 indexed response
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

    constructor() ConfirmedOwner(msg.sender) {
        setPublicChainlinkToken();
        oracle = 0xBa6396EbfA52fcd4F24B2338eA26aDC0b07F0AC2;
        jobId = "53c081cf45a14ba4b08257af5b3e753d";
        fee = 0.1 * 10**18;
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

    function requestInt(int256 x, int256 y) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(jobId),
            address(this),
            this.fulfillInt.selector
        );
        req.addInt("x", x);
        req.addInt("y", y);
        sendChainlinkRequestTo(oracle, req, fee);
        responseInt = 10;
    }

    function fulfillInt(bytes32 _requestId, int256 data)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestIntFullfiled(_requestId, data);
        responseInt = data;
    }

    function fulfillBytes(bytes32 _requestId, bytes32 data)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestBytesFullfiled(_requestId, data);
        responseBytes = data;
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
