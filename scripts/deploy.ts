// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { Contract } from "ethers";
import { ethers } from "hardhat";

async function deploy(
  artifact: string,
  params?: Array<unknown>
): Promise<Contract> {
  const Contract = await ethers.getContractFactory(artifact);
  const contract = params
    ? await Contract.deploy(...params)
    : await Contract.deploy();

  await contract.deployed();

  console.log(`${artifact} contract deployed to: ${contract.address}`);

  return contract;
}

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const registry = await deploy("contracts/Registry.sol:Registry");

  const fundManager = await deploy("contracts/FundManager.sol:FundManager");
  await registry.register("FUND_MANAGER", fundManager.address);

  const deposit = await deploy("contracts/Deposit.sol:Deposit");
  await registry.register("DEPOSIT", deposit.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
