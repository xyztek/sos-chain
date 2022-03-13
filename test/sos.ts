import { expect } from "chai";
import { Contract, ContractReceipt } from "ethers";
import { ethers } from "hardhat";

import { deployERC20, deployStack, Stack } from "../scripts/helpers";
import testSVG from "./testSVG";

describe("SOS", function () {
  let stack: Stack;
  let ERC20: Contract;

  before(async function () {
    const [owner] = await ethers.getSigners();

    stack = await deployStack({ SOSMinter: owner.address });

    ERC20 = await deployERC20();
  });

  it("should mint an ERC721", async function () {
    const [_owner, EOA1] = await ethers.getSigners();
    await expect(() =>
      stack.SOS.mint(
        EOA1.address,
        0,
        ethers.constants.WeiPerEther.mul(1000),
        ERC20.address
      )
    ).to.changeTokenBalance(stack.SOS, EOA1, 1);
  });

  it("should return a token URI for an ERC721", async function () {
    const [owner] = await ethers.getSigners();

    await stack.FundManager.createFund(
      "Test Fund",
      "Test Focus",
      "Test Description Text",
      [ERC20.address],
      owner.address
    );

    const tx = await stack.SOS.mint(
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      0,
      ethers.constants.WeiPerEther.mul(1000),
      ERC20.address
    );

    const receipt: ContractReceipt = await tx.wait();
    const event = receipt.events?.filter((x) => x.event == "Transfer")[0];

    const tokenURI = await stack.SOS.tokenURI(event?.args?.tokenId!);

    const encodedSVG = Buffer.from(testSVG).toString("base64");

    const buffer = Buffer.from(
      `{"name":"SOS Chain", "description": "SOS Chain Donation NFT", "image": "data:image/svg+xml;base64,${encodedSVG}"}`
    );

    const [def, encoded] = tokenURI.split(",");
    const encodedBuffer = buffer.toString("base64");

    expect(def).to.equal("data:application/json;base64");
    expect(encoded).to.equal(encodedBuffer);
  });
});
