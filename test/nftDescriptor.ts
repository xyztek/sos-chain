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

  it("should construct an SVG representation", async function () {
    const [_owner, EOA1] = await ethers.getSigners();
    const tokenSVG = await stack.Descriptor.buildSVG(
      2,
      EOA1.address,
      ethers.utils.parseUnits("120", await ERC20.decimals()),
      ERC20.address,
      "Test Fund",
      "Test Focus"
    );
    expect(tokenSVG).to.equal(testSVG(EOA1.address));
  });

  it("should construct a Base64 encoded SVG representation", async function () {
    const [_owner, EOA1] = await ethers.getSigners();
    const encodedSVG = await stack.Descriptor.encodeSVG(
      2,
      EOA1.address,
      ethers.utils.parseUnits("120", await ERC20.decimals()),
      ERC20.address,
      "Test Fund",
      "Test Focus"
    );

    expect(encodedSVG).to.equal(
      Buffer.from(testSVG(EOA1.address)).toString("base64")
    );
  });

  it("should format a uint256 as fixed point", async function () {
    const [_owner, EOA1] = await ethers.getSigners();
    const decimals = await ERC20.decimals();

    const cases = [
      [ethers.utils.parseUnits("120", decimals), "120"],
      [ethers.utils.parseUnits("120.3", decimals), "120.30000"],
      [ethers.utils.parseUnits("1.20", decimals), "1.20000"],
      [ethers.utils.parseUnits("1.2", decimals), "1.20000"],
      [ethers.utils.parseUnits("0.20", decimals), "0.20000"],
      [ethers.utils.parseUnits("0.0020", decimals), "0.00200"],
    ];

    for (const [amount, expected] of cases) {
      const formatted = await stack.Descriptor.formatUint(5, decimals, amount);
      expect(formatted).to.equal(expected);
    }
  });
});
