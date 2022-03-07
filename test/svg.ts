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
    expect(await this.svg.toPixelValue(112)).to.equal("112px");
  });

  it("should build an rgba value representation", async function () {
    expect(await this.svg.toRGBA("0", "0", "0", "0.5")).to.equal(
      "rgba(0,0,0,0.5)"
    );
  });

  it("should build a tag with empty content", async function () {
    const tag = await this.svg.tag(
      "svg",
      'width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg"',
      ""
    );

    expect(tag).to.equal(
      '<svg width="290" height="500" viewBox="0 0 290 500" xmlns="http://www.w3.org/2000/svg"></svg>'
    );
  });

  it("should build a tag with content", async function () {
    const tag = await this.svg.tag("text", 'font-size="1rem"', "ID #2929920");

    expect(tag).to.equal('<text font-size="1rem">ID #2929920</text>');
  });
});
