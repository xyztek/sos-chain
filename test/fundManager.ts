import { expect } from "chai";
import { Contract, ContractReceipt } from "ethers";

import { deployContract, deployStack, Stack } from "../scripts/helpers";

describe("FundManager.sol", function () {
  let stack: Stack;
  let contract: Contract;

  before(async () => {
    stack = await deployStack();
  });

  beforeEach(async () => {
    contract = await deployContract(
      "contracts/FundManager.sol:FundManager",
      {},
      [stack.Registry.address, stack.FundImplementation.address]
    );

    await expect(
      contract.createFund(
        "Test Fund",
        "Test Focus",
        "Test Description Text",
        ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
        "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
      )
    ).to.emit(contract, "FundCreated");
  });

  it("should emit a FundCreated event", async function () {
    const fundCreated = await contract.createFund(
      "Test Fund",
      "Test Focus",
      "Test Description Text",
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    );

    const receipt: ContractReceipt = await fundCreated.wait();

    const event = receipt.events?.find((x) => x.event == "FundCreated");

    expect(event).to.not.be.undefined;
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
