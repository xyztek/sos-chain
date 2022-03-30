import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { Contract, utils } from "ethers";
import { ethers } from "hardhat";
import { Stack, deployStack } from "../scripts/helpers";
import { deployMockOracleConsumer } from "../scripts/Deployments/oracle";

describe("MockOracleConsumer.sol", function () {
  let stack: Stack;
  let contract: Contract;
  let tokenContract: Contract;
  let oracleContract: Contract;
  let owner: SignerWithAddress;
  before(async function () {
    stack = await deployStack();
    tokenContract = stack.MockChainLinkToken;

    oracleContract = stack.OracleArgcis;
  });

  beforeEach(async () => {
    const [creator] = await ethers.getSigners();
    owner = creator;
    contract = await deployMockOracleConsumer(
      tokenContract.address,
      oracleContract.address
    );
  });

  it("should convert string to bytes", async () => {
    const respond = await contract.stringToBytes32("TEST");
    const expected =
      "0x5445535400000000000000000000000000000000000000000000000000000000";

    expect(respond).to.equal(expected);
  });

  it("should set properties ", async () => {
    const newOracleAddress = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";
    const newFee = 99;

    await contract.setOracle(newOracleAddress);
    await contract.setFee(newFee);

    expect(newFee === (await contract.fee()).toNumber()).to.true;
    expect(newOracleAddress).to.equal(await contract.oracle());
  });

  it("should withdraw links from oracle consumer", async () => {
    const oldBalance = await tokenContract.balanceOf(owner.address);
    console.log(oldBalance);
    await tokenContract.transfer(contract.address, utils.parseEther("10"));
    await contract.withdrawLink();
    const newBalance = await tokenContract.balanceOf(owner.address);

    expect(oldBalance).to.equal(newBalance);
  });

  it("should revert if oracle is not the one fullfiling request", async () => {
    await expect(
      contract.approveCheck(
        "0x3900000000000000000000000000000000000000000000000000000000000000",
        "0x3900000000000000000000000000000000000000000000000000000000000000"
      )
    ).to.be.reverted;
  });
});
