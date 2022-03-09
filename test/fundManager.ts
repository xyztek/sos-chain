import { expect } from "chai";
import { ethers } from "hardhat";
import { ContractFactory, Contract } from "ethers";

describe("FundManager", function () {
  let factory: ContractFactory;
  let contract: Contract;

  before(async () => {
    factory = await ethers.getContractFactory(
      "contracts/FundManager.sol:FundManager"
    );
  });

  beforeEach(async () => {
    contract = await factory.deploy();
    await contract.deployed();

    await contract.setupFund(
      "T01",
      "Test Fund",
      "Test",
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    );
  });

  it("should deploy a new fund", async function () {
    expect(await contract.getFundAddress("T01")).to.be.properAddress;
  });

  it("should return deposit address for a fund if token is allowed", async function () {
    const depositAddress = await contract.getDepositAddressFor(
      "T01",
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    );

    expect(depositAddress).to.be.properAddress;
  });

  it("should revert if token is not allowed for deposit", async function () {
    await expect(
      contract.getDepositAddressFor(
        "T01",
        "0xC250f11eD2989BB9A64f0BEDA9310CC33FD10D06"
      )
    ).to.be.reverted;
  });
});
