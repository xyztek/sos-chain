import { expect } from "chai";
import { ethers } from "hardhat";

describe("FundManager", function () {
  it("should deploy a new fund", async function () {
    const FundManager = await ethers.getContractFactory(
      "contracts/FundManager.sol:FundManager"
    );

    const fundManager = await FundManager.deploy();

    await fundManager.deployed();

    await fundManager.setupFund("T01", "Test Fund", [], []);

    expect(await fundManager.getFundAddress("T01")).to.be.properAddress;
  });

  it("should return deposit address for a fund if token is allowed", async function () {
    const FundManager = await ethers.getContractFactory(
      "contracts/FundManager.sol:FundManager"
    );

    const fundManager = await FundManager.deploy();

    await fundManager.deployed();

    await fundManager.setupFund(
      "T01",
      "Test Fund 1",
      [],
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"]
    );

    const depositAddress = await fundManager.getDepositAddressFor(
      "T01",
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    );

    expect(depositAddress).to.be.properAddress;
  });

  it("should revert if token is not allowed for deposit", async function () {
    const FundManager = await ethers.getContractFactory(
      "contracts/FundManager.sol:FundManager"
    );

    const fundManager = await FundManager.deploy();

    await fundManager.deployed();

    await fundManager.setupFund(
      "T01",
      "Test Fund 1",
      [],
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"]
    );

    await expect(
      fundManager.getDepositAddressFor(
        "T01",
        "0xC250f11eD2989BB9A64f0BEDA9310CC33FD10D06"
      )
    ).to.be.reverted;
  });
});
