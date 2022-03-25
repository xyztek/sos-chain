import { expect } from "chai";
import { ContractFactory, Contract } from "ethers";
import { ethers } from "hardhat";

import { asBytes32 } from "../scripts/helpers";

describe("Registry.sol", function () {
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

    await contract.batchRegister(
      [asBytes32("TEST_101"),asBytes32("TEST_102")],
      ["0x488e3a4Bbbb2386bA619Eed88319E807C3dDb6C2",
      "0xBB0E17EF65F82Ab018d8EDd776e8DD940327B28b"]
    );

    await contract.batchUpdate(
      [asBytes32("FUND_MANAGER"),asBytes32("GOVERNOR")],
      ["0xe7f1725e7734ce288f8367e1bb143e90bb3f0512",
      "0xc3e53f4d16ae77db1c982e75a937b9f60fe63690"]
    );

    await contract.register(
      asBytes32("FUND_MANAGER"),
      "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"
    );

    await contract.register(
      asBytes32("GOVERNOR"),
      "0xc3e53f4d16ae77db1c982e75a937b9f60fe63690"
    );
  });

  it("should register and return a registered address", async function () {
    expect(await contract.get(asBytes32("FUND_MANAGER"))).to.be.hexEqual(
      "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512"
    );
  });

  it("should register and return registered addresses", async function () {
    const values = [
      "TEST_101",
      "TEST_102",
      ].map((value) => asBytes32(value));
    const addresses = await contract.batchGet(values);
    expect(addresses[0]).to.be.hexEqual("0x488e3a4Bbbb2386bA619Eed88319E807C3dDb6C2");
    expect(addresses[1]).to.be.hexEqual("0xBB0E17EF65F82Ab018d8EDd776e8DD940327B28b");
  });
  
  it("should update registered addresses", async function () {
    await contract.batchUpdate(
      [asBytes32("FUND_MANAGER"),asBytes32("GOVERNOR")],
      ["0xe7f1725e7734ce288f8367e1bb143e90bb3f0512",
      "0xc3e53f4d16ae77db1c982e75a937b9f60fe63690"]
    );
    
    const values = [
      "FUND_MANAGER",
      "GOVERNOR",
      ].map((value) => asBytes32(value));
    const addresses = await contract.batchGet(values);
    expect(addresses[0]).to.be.hexEqual("0xe7f1725e7734ce288f8367e1bb143e90bb3f0512");
    expect(addresses[1]).to.be.hexEqual("0xc3e53f4d16ae77db1c982e75a937b9f60fe63690");
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

  it("should return the contract names in an address array", async function () {
    const values = [
      "TEST_101",
      "TEST_102",
      ].map((value) => asBytes32(value));
    const addresses = await contract.batchGet(values);
    expect(addresses[0]).to.be.hexEqual("0x488e3a4Bbbb2386bA619Eed88319E807C3dDb6C2");
    expect(addresses[1]).to.be.hexEqual("0xBB0E17EF65F82Ab018d8EDd776e8DD940327B28b");
  });

});
