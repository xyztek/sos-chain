import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

import { deployERC20, deployStack, Stack } from "../scripts/helpers";
import testSVG from "./testSVG";

describe("NFTDescriptor.sol", function () {
  let stack: Stack;
  let ERC20: Contract;

  before(async function () {
    stack = await deployStack();
    ERC20 = await deployERC20();
  });

  it("should construct SVG representation", async function () {
    const tokenSVG = await stack.Descriptor.buildSVG(
      2,
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      ethers.constants.WeiPerEther.mul(1000),
      ERC20.address,
      "Test Fund",
      "Test Focus"
    );

    expect(tokenSVG).to.equal(testSVG);
  });

  it("should construct a Base64 encoded SVG representation", async function () {
    const encodedSVG = await stack.Descriptor.encodeSVG(
      2,
      "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
      ethers.constants.WeiPerEther.mul(1000),
      ERC20.address,
      "Test Fund",
      "Test Focus"
    );

    expect(encodedSVG).to.equal(Buffer.from(testSVG).toString("base64"));
  });
});
