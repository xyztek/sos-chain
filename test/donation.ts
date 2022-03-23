import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

import {
  createFund,
  deployERC20,
  deployStack,
  Stack,
} from "../scripts/helpers";

describe("Donation.sol", function () {
  let stack: Stack;
  let ERC20: Contract;

  let DECIMALS: BigNumber;

  before(async () => {
    const [_owner, _EOA1, EOA2] = await ethers.getSigners();

    stack = await deployStack();
    ERC20 = await deployERC20();

    DECIMALS = await ERC20.decimals();

    await createFund(
      stack.FundManager,
      [ERC20.address],
      EOA2.address,
      false,
      []
    );
  });

  it("should accept a donation and deposit into the safe", async function () {
    const [_owner, EOA1, EOA2] = await ethers.getSigners();

    const donationAmount = ethers.utils.parseUnits("12", DECIMALS);

    await ERC20.transfer(EOA1.address, donationAmount);
    await ERC20.connect(EOA1).approve(stack.Donation.address, donationAmount);

    await expect(() =>
      stack.Donation.connect(EOA1).donate(0, ERC20.address, donationAmount)
    ).to.changeTokenBalance(ERC20, EOA2, donationAmount);
  });

  it("should mint an ERC721 and transfer to donator", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    const donationAmount = ethers.utils.parseUnits("12", DECIMALS);

    await ERC20.transfer(EOA1.address, donationAmount);
    await ERC20.connect(EOA1).approve(stack.Donation.address, donationAmount);

    await expect(() =>
      stack.Donation.connect(EOA1).donate(0, ERC20.address, donationAmount)
    ).to.changeTokenBalance(stack.SOS, EOA1, 1);
  });

  it("should emit a Donated event", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    const donationAmount = ethers.utils.parseUnits("12", DECIMALS);

    await ERC20.transfer(EOA1.address, donationAmount);
    await ERC20.connect(EOA1).approve(stack.Donation.address, donationAmount);

    await expect(
      stack.Donation.connect(EOA1).donate(0, ERC20.address, donationAmount)
    ).to.emit(stack.Donation, "Donated");
  });

  it("should revert early if allowance is insufficient", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    const donationAmount = ethers.utils.parseUnits("12", DECIMALS);

    await ERC20.transfer(EOA1.address, donationAmount);

    await expect(
      stack.Donation.connect(EOA1).donate(0, ERC20.address, donationAmount)
    ).to.be.revertedWith("ERC20: insufficient allowance");
  });

  it("should revert early if token is not allowed", async function () {
    const anotherERC20 = await deployERC20();

    const donationAmount = ethers.utils.parseUnits("12", DECIMALS);

    await expect(
      stack.Donation.donate(0, anotherERC20.address, donationAmount)
    ).to.be.revertedWith("NotAllowed");
  });
});
