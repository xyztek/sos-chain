import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";

import { deployERC20, deployStack, Stack } from "../scripts/helpers";

describe("Donation.sol", function () {
  let stack: Stack;
  let ERC20: Contract;

  before(async () => {
    const [_owner, _EOA1, EOA2] = await ethers.getSigners();

    stack = await deployStack();
    ERC20 = await deployERC20();

    await stack.FundManager.createFund(
      "Test Fund",
      "Test Focus",
      "Test Description Text",
      [ERC20.address],
      EOA2.address
    );
  });

  it("should accept a donation and deposit into the safe", async function () {
    const [_owner, EOA1, EOA2] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);
    await ERC20.connect(EOA1).approve(stack.Donation.address, 1000000);

    await expect(() =>
      stack.Donation.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.changeTokenBalance(ERC20, EOA2, 1000000);
  });

  it("should mint an ERC721 and transfer to donator", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);
    await ERC20.connect(EOA1).approve(stack.Donation.address, 1000000);

    await expect(() =>
      stack.Donation.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.changeTokenBalance(stack.SOS, EOA1, 1);
  });

  it("should emit a Donated event", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);
    await ERC20.connect(EOA1).approve(stack.Donation.address, 1000000);

    await expect(
      stack.Donation.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.emit(stack.Donation, "Donated");
  });

  it("should revert early if allowance is insufficient", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);

    await expect(
      stack.Donation.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.be.revertedWith("ERC20: insufficient allowance");
  });

  it("should revert early if token is not allowed", async function () {
    const anotherERC20 = await deployERC20();

    await expect(
      stack.Donation.donate(0, anotherERC20.address, 1000000)
    ).to.be.revertedWith("NotAllowed");
  });
});
