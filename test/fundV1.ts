import { assert, expect } from "chai";
import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";

import {
  createFund,
  deployERC20,
  deployStack,
  Stack,
} from "../scripts/helpers";

describe("FundV1.sol", function () {
  let stack: Stack;
  let factory: ContractFactory;
  let USDC: Contract;
  let funds: string[];
  let safeAddress: string;

  before(async () => {
    const [_owner, EOA1, _EOA2] = await ethers.getSigners();

    safeAddress = EOA1.address;

    USDC = await deployERC20("USD Coin", "USDC");

    stack = await deployStack();

    factory = await ethers.getContractFactory("FundV1");

    await createFund(
      stack.FundManager,
      [USDC.address],
      EOA1.address,
      false,
      []
    );

    funds = await stack.FundManager.getFunds();
  });

  it("should return meta information", async function () {
    const [name, focus] = await factory.attach(funds[0]).getMeta();
    expect(name).to.equal("Test Fund");
    expect(focus).to.equal("Test Focus");
  });

  it("should return deposit address", async function () {
    expect(
      await factory.attach(funds[0]).getDepositAddressFor(USDC.address)
    ).to.eq(safeAddress);
  });

  it("should revert if token is not allowed for deposit", async function () {
    await expect(
      factory
        .attach(funds[0])
        .getDepositAddressFor("0xC250f11eD2989BB9A64f0BEDA9310CC33FD10D06")
    ).to.be.reverted;
  });

  it("should return safe balances", async function () {
    const balances = await factory.attach(funds[0]).getBalances();
    assert(balances[0].length == balances[1].length);
  });

  it("should be resumable only if paused", async function () {
    await expect(factory.attach(funds[0]).resume()).to.be.revertedWith(
      "NotAllowed()"
    );
  });

  it("should be pausable", async function () {
    await factory.attach(funds[0]).pause();
    expect(await factory.attach(funds[0]).status()).to.eq(1);
  });

  it("should be resumable", async function () {
    await factory.attach(funds[0]).resume();
    expect(await factory.attach(funds[0]).status()).to.eq(0);
  });

  it("should be closable", async function () {
    await factory.attach(funds[0]).close();
    expect(await factory.attach(funds[0]).status()).to.eq(2);
  });

  it("should stay closed forever", async function () {
    await expect(factory.attach(funds[0]).resume()).to.be.revertedWith(
      "NotAllowed()"
    );
  });

  it("should not allow call to updateBalance method", async function () {
    const donationAmount = ethers.utils.parseUnits("12", 18);

    await expect(
      factory.attach(funds[0]).updateBalance(USDC.address, donationAmount)
    ).to.be.revertedWith("AccessControl");
  });
});
