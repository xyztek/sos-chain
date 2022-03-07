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

  it("should build a padded key=value string", async function () {
    expect(await this.svg.toRPaddedAttributePair("width", "250px")).to.equal(
      'width="250px" '
    );
  });

  it("should draw a rectangle", async function () {
    expect(
      await this.svg.drawRect(
        "50",
        "50",
        "250px",
        "250px",
        "20px",
        "none",
        "none"
      )
    ).to.equal(
      '<rect x="50" y="50" width="250px" height="250px" rx="20px" ry="20px" stroke="none" fill="none" />'
    );
  });
});
