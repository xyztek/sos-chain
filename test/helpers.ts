import { ContractFactory, Contract } from "ethers";
import { ethers } from "hardhat";

export function asBytes32(str: string) {
  return ethers.utils.formatBytes32String(str);
}

export async function getAddress(
  registry: Contract,
  name: string
): Promise<string> {
  const asBytes32 = ethers.utils.formatBytes32String(name);
  return registry.get(asBytes32);
}

export async function registerAddress(
  registry: Contract,
  name: string,
  address: string
): Promise<void> {
  const asBytes32 = ethers.utils.formatBytes32String(name);
  await registry.register(asBytes32, address);
}

export async function deployContract(
  artifact: string,
  args: unknown[] = []
): Promise<Contract> {
  const factory: ContractFactory = await ethers.getContractFactory(artifact);
  const contract = args.length
    ? await factory.deploy(...args)
    : await factory.deploy();

  return contract.deployed();
}

export async function deployERC20(
  initialBalance = 1000000000000
): Promise<Contract> {
  return deployContract("contracts/test/BasicERC20.sol:BasicERC20", [
    initialBalance,
  ]);
}

export async function deployRegistry(): Promise<Contract> {
  return deployContract("contracts/Registry.sol:Registry");
}

export async function deployFundManager(): Promise<Contract> {
  const implementation = await deployContract("contracts/FundV1.sol:FundV1");

  return deployContract("contracts/FundManager.sol:FundManager", [
    implementation.address,
  ]);
}
