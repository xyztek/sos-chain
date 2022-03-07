// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";

async function deploy(
  artifact: string,
  params?: Array<unknown>
): Promise<[Contract, ContractFactory]> {
  const Contract = await ethers.getContractFactory(artifact);
  const contract = params
    ? await Contract.deploy(...params)
    : await Contract.deploy();

  await contract.deployed();

  console.log(`${artifact} contract deployed to: ${contract.address}`);

  return [contract, Contract];
}

function toBytes(str: string) {
  return ethers.utils.toUtf8Bytes(str);
}

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const provider = new ethers.providers.JsonRpcProvider();

  const [registry, _registryFactory] = await deploy(
    "contracts/Registry.sol:Registry"
  );

  let register = async (name: string, contract: Contract) => {
    await registry.register(ethers.utils.toUtf8Bytes(name), contract.address);
  };

  const [fundManager, fundManagerFactory] = await deploy(
    "contracts/FundManager.sol:FundManager"
  );
  await register("FUND_MANAGER", fundManager);

  const [deposit, _depositFactory] = await deploy(
    "contracts/Deposit.sol:Deposit"
  );
  await register("DEPOSIT", deposit);

  const fundAddress = await fundManagerFactory
    .attach(fundManager.address)
    .setupFund(toBytes("T01"), "Test Fund", []);

  console.log(fundAddress);

  const fund = (
    await ethers.getContractFactory("contracts/Fund.sol:Fund")
  ).attach(fundAddress);

  await fund.addToken("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

  console.log(await fund.getAllowedTokens());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
