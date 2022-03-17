// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { ethers } from "hardhat";
import { Contract } from "ethers";

import { ContractName, deployERC20, deployStack } from "./helpers";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const [owner, _EOA1, _EOA2] = await ethers.getSigners();

  console.log(`Deployed by ${owner.address}`);

  const USDC = await deployERC20("USD Coin", "USDC");
  console.log(`Fake USDC contract deployed at ${USDC.address}`);

  const stack = await deployStack();

  await stack.FundManager.createFund(
    "Test Fund 001",
    "Test Focus A",
    "Test Description Text",
    [USDC.address],
    owner.address
  );

  await stack.FundManager.createFund(
    "Test Fund 002",
    "Test Focus B",
    "Test Description Text",
    [USDC.address],
    owner.address
  );

  Object.keys(stack).forEach((key: string) => {
    const contract: Contract = stack[key as ContractName];
    console.log(`${key} contract deployed at ${contract.address}`);
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
