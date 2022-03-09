import { expect } from "chai";
import { ethers } from "hardhat";

describe("SVG", function () {
  before(async function () {
    this.SVG = await ethers.getContractFactory("SVG");
  });

  beforeEach(async function () {
    this.svg = await this.SVG.deploy();
    await this.svg.deployed();
  });

  it("should convert a uint256 value to px representation", async function () {
    const asBytes = await this.svg.toPixelValue(112);
    const value = ethers.utils.toUtf8String(asBytes);
    expect(value).to.equal("112px");
  });

  it("should build an rgba value representation", async function () {
    const asBytes = await this.svg.toRGBA("0", "0", "0", "0.5");
    const value = ethers.utils.toUtf8String(asBytes);
    expect(value).to.equal("rgba(0,0,0,0.5)");
  });

  it("should build a tag with empty content", async function () {
    const asBytes = await this.svg.tag(
      ethers.utils.formatBytes32String("svg"),
      ethers.utils.formatBytes32String('viewBox="0 0 290 500"'),
      ethers.utils.formatBytes32String("")
    );

    const value = ethers.utils.toUtf8String(asBytes).replace(/\0/g, "");

    expect(value).to.equal('<svg viewBox="0 0 290 500"></svg>');
  });

  it("should build a tag with content", async function () {
    const asBytes = await this.svg.tag(
      ethers.utils.formatBytes32String("text"),
      ethers.utils.formatBytes32String('font-size="1rem"'),
      ethers.utils.formatBytes32String("ID #2929920")
    );

    const value = ethers.utils.toUtf8String(asBytes).replace(/\0/g, "");

    expect(value).to.equal('<text font-size="1rem">ID #2929920</text>');
  });
});
