import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber, Contract } from "ethers";

import { deployERC20, deployStack, grantRole, Stack } from "../scripts/helpers";

describe("Governor.sol", function () {
  let stack: Stack;
  let ERC20: Contract;
  let requestAmount: BigNumber;

  const initialChecks = [
    "TEST_CHECK_001",
    "TEST_CHECK_002",
    "TEST_CHECK_003",
  ].map((check) => ethers.utils.formatBytes32String(check));

  const createRequest = async (recipient: string) => {
    return stack.Governor.createRequest(
      requestAmount,
      recipient,
      0,
      [2000000000000, 1000000000000],
      "Description"
    );
  };

  before(async () => {
    stack = await deployStack();
    ERC20 = await deployERC20();

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

  it("should return a list of remaining checks for a request", async function () {
    const remainingChecks = await stack.Governor.getRemainingChecks(0);

    expect(remainingChecks).to.have.members(initialChecks);
  });

  it("should revert an approve call if msg.sender lacks APPROVER_ROLE", async function () {
    const [_owner, EOA1] = await ethers.getSigners();
    await expect(
      stack.Governor.connect(EOA1).approveRequest(0, initialChecks[0])
    ).to.revertedWith("AccessControl");
  });

  it("should approve a check if msg.send has APPROVER_ROLE", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await grantRole(stack.Governor, "APPROVER_ROLE", EOA1.address);

    await stack.Governor.connect(EOA1).approveRequest(0, initialChecks[0]);

    const remainingChecks = await stack.Governor.getRemainingChecks(0);

    expect(remainingChecks).to.have.members(initialChecks.slice(1));
  });

  it("should map the approver's address to check on approval", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    expect(await stack.Governor.getApprover(0, initialChecks[0])).to.hexEqual(
      EOA1.address
    );
  });

  it("should not reapprove a previously approved check", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await expect(
      stack.Governor.connect(EOA1).approveRequest(0, initialChecks[0])
    ).to.be.revertedWith("NotAllowed()");
  });

  it("should return approved checks and their approvers", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    const [checks, approvers] = await stack.Governor.getApprovedChecks(0);

    expect(checks).to.have.members(initialChecks.slice(0, 1));
    expect(approvers).to.have.members([EOA1.address]);
  });
});
