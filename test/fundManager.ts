import { expect } from "chai";
import { ethers } from "hardhat";
import { ContractFactory, Contract } from "ethers";

describe("FundManager", function () {
  let factory: ContractFactory;
  let contract: Contract;

  let implementationAddress: string;

  before(async () => {
    const implementationFactory = await ethers.getContractFactory(
      "contracts/FundV1.sol:FundV1"
    );

    const implementation = await implementationFactory.deploy();
    await implementation.deployed();

    implementationAddress = implementation.address;

    factory = await ethers.getContractFactory(
      "contracts/FundManager.sol:FundManager"
    );
  });

  beforeEach(async () => {
    contract = await factory.deploy(implementationAddress);
    await contract.deployed();

    await expect(
      contract.createFund(
        "Test Fund",
        "Test",
        ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
        "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
      )
    ).to.emit(contract, "FundCreated");
  });

  it("should return the address of a fund", async function () {
    expect(await contract.getFundAddress(0)).to.be.properAddress;
  });

  it("should return deposit address for a fund if token is allowed", async function () {
    const depositAddress = await contract.getDepositAddressFor(
      0,
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    );

    expect(depositAddress).to.be.properAddress;
  });

  it("should revert if token is not allowed for deposit", async function () {
    await expect(
      contract.getDepositAddressFor(
        0,
        "0xC250f11eD2989BB9A64f0BEDA9310CC33FD10D06"
      )
    ).to.be.reverted;
  });
});
