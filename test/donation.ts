import { expect } from "chai";
import { ContractFactory, Contract } from "ethers";
import { ethers } from "hardhat";

import {
  asBytes32,
  deployContract,
  deployERC20,
  deployFundManager,
  deployRegistry,
} from "./helpers";

describe("Donation.sol", function () {
  let registry: Contract;
  let factory: ContractFactory;
  let contract: Contract;

  let fundManager: Contract;
  let ERC20: Contract;
  let SOS: Contract;

  before(async () => {
    registry = await deployRegistry();
    ERC20 = await deployERC20();

    fundManager = await deployFundManager();
    await registry.register(asBytes32("FUND_MANAGER"), fundManager.address);

    const [_owner, _EOA1, EOA2] = await ethers.getSigners();

    await fundManager.createFund(
      "Test Fund",
      "Test",
      [ERC20.address],
      EOA2.address
    );

    const svg = await deployContract("SVG");

    const descriptorFactory = await ethers.getContractFactory("NFTDescriptor", {
      libraries: { SVG: svg.address },
    });

    const descriptor = await descriptorFactory.deploy();

    await registry.register(asBytes32("NFT_DESCRIPTOR"), descriptor.address);

    factory = await ethers.getContractFactory(
      "contracts/Donation.sol:Donation"
    );

    contract = await factory.deploy(registry.address);

    await contract.deployed();

    SOS = await deployContract("SOS", [registry.address, contract.address]);
    await registry.register(asBytes32("SOS"), SOS.address);
  });

  beforeEach(async function () {});

  it("should accept a donation and deposit into the safe", async function () {
    const [_owner, EOA1, EOA2] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);
    await ERC20.connect(EOA1).approve(contract.address, 1000000);

    await expect(() =>
      contract.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.changeTokenBalance(ERC20, EOA2, 1000000);
  });

  it("should mint an ERC721 and transfer to donator", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);
    await ERC20.connect(EOA1).approve(contract.address, 1000000);

    await expect(() =>
      contract.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.changeTokenBalance(SOS, EOA1, 1);
  });

  it("should emit a Donated event", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);
    await ERC20.connect(EOA1).approve(contract.address, 1000000);

    await expect(
      contract.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.emit(contract, "Donated");
  });

  it("should revert early if allowance is insufficient", async function () {
    const [_owner, EOA1] = await ethers.getSigners();

    await ERC20.transfer(EOA1.address, 1000000);

    await expect(
      contract.connect(EOA1).donate(0, ERC20.address, 1000000)
    ).to.be.revertedWith("ERC20: insufficient allowance");
  });

  it("should revert early if token is not allowed", async function () {
    const anotherERC20 = await deployERC20();

    await expect(
      contract.donate(0, anotherERC20.address, 1000000)
    ).to.be.revertedWith("NotAllowed");
  });
});
