import { expect } from "chai";
import { ContractFactory, Contract } from "ethers";
import { ethers } from "hardhat";

describe("RequestManager", function () {
  let factory: ContractFactory;
  let contract: Contract;

  before(async () => {
    factory = await ethers.getContractFactory(
      "contracts/RequestManager.sol:RequestManager"
    );
  });

  beforeEach(async function () {
    const initialChecks = ["TEST_CHECK_01"];

    contract = await factory.deploy(
      initialChecks.map((check) => ethers.utils.formatBytes32String(check))
    );

    await contract.deployed();
  });

  it("should create a request", async function () {
    await expect(
      contract.createRequest(
        ethers.utils.formatBytes32String("TEST"),
        10000,
        "0xe7f1725e7734ce288f8367e1bb143e90bb3f0512",
        0,
        [0, 0]
      )
    ).to.emit(contract, "RequestCreated");
  });
});
