import { ContractFactory, Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import { FactoryOptions } from "hardhat/types";
import { deployContract, DeploymentOptions } from "../helpers";

export async function deployGnosisSafeProxyFactory(): Promise<Contract> {
  return deployContract(
    "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol:GnosisSafeProxyFactory",
    {},
    []
  );
}

export async function deployGnosisSafe(): Promise<Contract> {
  return deployContract(
    "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol:GnosisSafe",
    {},
    []
  );
}

export type GnosisNames = "GnosisSafe" | "GnosisSafeProxyFactory";
export type GnosisStack = Record<GnosisNames, Contract>;

export async function deployGnosisStack(): Promise<GnosisStack> {
  const GnosisSafe = await deployGnosisSafe();
  const GnosisSafeProxyFactory = await deployGnosisSafeProxyFactory();

  return {
    GnosisSafe,
    GnosisSafeProxyFactory,
  };
}
