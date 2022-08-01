import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber, Contract } from "ethers";

import {
  createFund,
  deployERC20,
  deployStack,
  grantRole,
  Stack,
} from "../scripts/helpers";

describe("Governor.sol", function () {
  let stack: Stack;
  let ERC20: Contract;
  let requestAmount: BigNumber;

  const createRequest = async (recipient: string) => {
    return stack.Governor.createRequest(
      requestAmount,
      ERC20.address,
      recipient,
      0,
      [
        ethers.utils.parseUnits("256.12903", 10),
        ethers.utils.parseUnits("123.4833", 10),
      ],
      "Description"
    );
  };

  before(async () => {
    const [_owner, _EOA1, EOA2] = await ethers.getSigners();

    stack = await deployStack();
    ERC20 = await deployERC20();

    await createFund(stack.FundManager, [ERC20.address], EOA2.address, true);
    requestAmount = ethers.utils.parseUnits("1000", await ERC20.decimals());
  });

  it("should create a request", async function () {
    const [_owner, _EOA1, EOA2] = await ethers.getSigners();

    const recipient = EOA2.address;

    await expect(createRequest(recipient)).to.emit(
      stack.Governor,
      "RequestCreated"
    );
  });

  it("should revert an approve call if msg.sender lacks APPROVER_ROLE", async function () {
    const [_owner, EOA1] = await ethers.getSigners();
    const role = ethers.utils.keccak256(
      ethers.utils.toUtf8Bytes("APPROVER_ROLE")
    );
    await expect(
      stack.Governor.connect(EOA1).approveCheck(0, 0, true)
    ).to.revertedWith(`MissingRole("${role}")`);
  });

  it("should approve a check if msg.send has APPROVER_ROLE", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    const fundAddress = await stack.FundManager.getFundAddress(0);

    const fund = (await ethers.getContractFactory("FundV1")).attach(
      fundAddress
    );

    await grantRole(fund, "APPROVER_ROLE", EOA1.address);

    await stack.Governor.connect(EOA1).approveCheck(0, 0, true);

    const pendingChecks = await stack.Governor.getPendingChecksCount(0);

    expect(pendingChecks).to.eq(2);
  });

  it("should map the approver's address to check on approval", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    expect(await stack.Governor.getSigner(0, 0)).to.hexEqual(EOA1.address);
  });

  it("should not reapprove a previously approved check", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await expect(
      stack.Governor.connect(EOA1).approveCheck(0, 0, true)
    ).to.be.revertedWith("NotAllowed()");
  });

  it("should return pending checks count", async function () {
    const [_owner, _EOA1] = await ethers.getSigners();

    const pendingChecks = await stack.Governor.getPendingChecksCount(0);

    expect(pendingChecks).to.eq(2);
  });

  it("should emit a Signed event", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await expect(stack.Governor.connect(EOA1).approveCheck(0, 1, true)).to.emit(
      stack.Governor,
      "Signed"
    );
  });

  it("should pack a request into bytes", async function () {
    const packed = await stack.Governor._packRequestWithCheck(0, 0);

    expect(packed).to.hexEqual(
      "Hex string representing the same number as 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025458cc6a600000000000000000000000000000000000000000000000000000011f81c846400000000000000000000000003c44cdddb6a900fa2b585dd299e03d12fa4293bc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003635c9adc5dea00000000000000000000000000000525c7063e7c20997baae9bda922159152d0e8417"
    );
  });
});
