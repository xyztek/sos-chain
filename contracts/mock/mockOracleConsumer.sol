// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

import "hardhat/console.sol";

contract MockOracleConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public fee;

    address public oracle;

    event RequestFullfiled(
        bytes32 indexed _requestId,
        uint256 indexed _checkId,
        uint256 indexed _govRequestId,
        bool _success
    );

    function setOracle(address _oracle) public onlyOwner {
        oracle = _oracle;
    }

    function setFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    constructor(address _oracle, address _linkAddress)
        ConfirmedOwner(msg.sender)
    {
        setChainlinkToken(_linkAddress);
        oracle = _oracle;
        fee = 10**17;
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
        bool _data,
        uint256 _checkId,
        uint256 _govRequestId
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestFullfiled(_requestId, _checkId, _govRequestId, _data);
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
        public
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
