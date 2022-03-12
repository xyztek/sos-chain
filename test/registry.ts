import { expect } from "chai";
import { ContractFactory, Contract } from "ethers";
import { ethers } from "hardhat";

import { asBytes32 } from "./helpers";

describe("Registry", function () {
  let factory: ContractFactory;
  let contract: Contract;

  before(async () => {
    factory = await ethers.getContractFactory(
      "contracts/Registry.sol:Registry"
    );
  });

  beforeEach(async function () {
    contract = await factory.deploy();
    await contract.deployed();

    const registration = await contract.register(
      asBytes32("FUND_MANAGER"),
      "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"
    );

    await registration.wait();
  });

  it("should register and return a registered address", async function () {
    expect(await contract.get(asBytes32("FUND_MANAGER"))).to.be.hexEqual(
      "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"
    );
  });

  it("should update a registered address", async function () {
    await contract.update(
      asBytes32("FUND_MANAGER"),
      "0xc3e53f4d16ae77db1c982e75a937b9f60fe63690"
    );

    expect(await contract.get(asBytes32("FUND_MANAGER"))).to.be.hexEqual(
      "0xc3e53f4d16ae77db1c982e75a937b9f60fe63690"
    );
  });
});
