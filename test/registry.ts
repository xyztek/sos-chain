import { expect } from "chai";
import { ethers } from "hardhat";

describe("Registry", function () {
  beforeEach(async function () {
    this.factory = await ethers.getContractFactory(
      "contracts/Registry.sol:Registry"
    );
    this.registry = await this.factory.deploy();
    await this.registry.deployed();
  });

  it("should register and return a registered address", async function () {
    await this.registry.register(
      "FUND_MANAGER",
      "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"
    );

    expect(await this.registry.get("FUND_MANAGER")).to.be.hexEqual(
      "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"
    );
  });

  it("should revert if already registered", async function () {
    await this.registry.register(
      "FUND_MANAGER",
      "0xc3e53f4d16ae77db1c982e75a937b9f60fe63690"
    );

    await expect(
      this.registry.register(
        "FUND_MANAGER",
        "0xc3e53f4d16ae77db1c982e75a937b9f60fe63690"
      )
    ).to.be.reverted;
  });
});
