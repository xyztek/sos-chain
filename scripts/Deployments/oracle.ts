import { ContractFactory, Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import { FactoryOptions } from "hardhat/types";
import { deployContract, DeploymentOptions } from "../helpers";

export async function deployMockOracleConsumer(
  chainLink: string,
  oracle: string,
  jobId = "834f1c7da06e4df6854b5880488598e0",
  fee = ethers.utils.parseEther("0.1")
): Promise<Contract> {
  return deployContract(
    "contracts/mock/mockOracleConsumer.sol:MockOracleConsumer",
    {},
    [oracle, chainLink]
  );
}

export async function deployMockChainLinkToken(): Promise<Contract> {
  return deployContract(
    "contracts/mock/mockChainLinkToken.sol:MockLinkToken",
    {},
    []
  );
}

export async function deployOracleArgcis(chainLink: string): Promise<Contract> {
  return deployContract("contracts/hybrid/OracleArgcis.sol:OracleArgcis", {}, [
    chainLink,
  ]);
}

export type OracleNames =
  | "MockChainLinkToken"
  | "OracleArgcis"
  | "MockOracleConsumer";
export type OracleStack = Record<OracleNames, Contract>;

export async function deployOracleStack(): Promise<OracleStack> {
  const MockChainLinkToken = await deployMockChainLinkToken();
  const OracleArgcis = await deployOracleArgcis(MockChainLinkToken.address);
  const MockOracleConsumer = await deployMockOracleConsumer(
    MockChainLinkToken.address,
    OracleArgcis.address
  );

  return {
    MockChainLinkToken,
    OracleArgcis,
    MockOracleConsumer,
  };
}
