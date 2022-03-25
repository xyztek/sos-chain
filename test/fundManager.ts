import { assert, expect } from "chai";

import { BigNumber, Contract, ContractFactory, ContractReceipt } from "ethers";

import { ethers } from "hardhat";

import {
  deployContract,
  deployGnosisSafe,
  deployGnosisSafeProxyFactory,
  createFund,
  deployStack,
  Stack,
} from "../scripts/helpers";

describe("FundManager.sol", function () {
  let stack: Stack;
  let contract: Contract;

  let mockGnosisProxyFactory: Contract;
  let mockGnosisSafe: Contract;

  let fundFactory: ContractFactory;
  let gnosisFactory: ContractFactory;

  before(async () => {
    stack = await deployStack();

    mockGnosisProxyFactory = await deployGnosisSafeProxyFactory();
    mockGnosisSafe = await deployGnosisSafe();
    fundFactory = await ethers.getContractFactory("FundV1");
    gnosisFactory = await ethers.getContractFactory("GnosisSafe");
  });

  beforeEach(async () => {
    contract = await deployContract(
      "contracts/FundManager.sol:FundManager",
      {},
      [stack.Registry.address, stack.FundImplementation.address]
    );

    await expect(
      createFund(
        contract,
        ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
        "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
        false,
        []
      )
    ).to.emit(contract, "FundCreated");
  });

  it("should deploy a Gnosis Safe and create a fund", async function () {
    const owner = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";

    const fundCreated = await contract.createFundWithSafe(
      "Test Fund",
      "Test Focus",
      "Test Description Text",
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
      false,
      [],
      [],
      [owner],
      1
    );

    const receipt: ContractReceipt = await fundCreated.wait();

    const event = receipt.events?.find((x) => x.event == "FundCreated");

    const fundAddress = await contract.getFundAddress(event?.args?.id);

    const gnosisSafeAddress = await fundFactory
      .attach(fundAddress)
      .getDepositAddressFor("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48");

    const isOwner = await gnosisFactory
      .attach(gnosisSafeAddress)
      .isOwner(owner);

    expect(isOwner).to.equal(true);
  });

  it("should revert if given threshold is greater than owners size", async function () {
    const owner = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4";

    await expect(
      contract.createFundWithSafe(
        "Test Fund",
        "Test Focus",
        "Test Description Text",
        ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
        false,
        [],
        [],
        [owner],
        5
      )
    ).to.be.revertedWith("NotAllowed()");
  });

  it("should create a fund given an ordinary EOA address", async function () {
    const fundCreated = await contract.createFund(
      "Test Fund",
      "Test Focus",
      "Test Description Text",
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
      false,
      [],
      []
    );

    const receipt: ContractReceipt = await fundCreated.wait();

    assert(receipt.events?.find((x) => x.event == "FundCreated"));
  });

  it("should return addresses of open funds", async function () {
    expect(await contract.getFunds()).to.be.not.empty;
  });

  it("should return the address of a fund", async function () {
    expect(await contract.getFundAddress(0)).to.be.properAddress;
  });

  it("should return a list of token addresses allowed for deposit", async function () {
    const depositAddress = await contract.getAllowedTokens(0);

    expect(depositAddress).to.be.properAddress;
  });

  it("should return a deposit address if token is allowed", async function () {
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
