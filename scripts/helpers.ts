import { ContractFactory, Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import { FactoryOptions } from "hardhat/types";

import { DeploymentsExtension } from "hardhat-deploy/types";
export type ContractName =
  | "Descriptor"
  | "Donation"
  | "FundManager"
  | "FundImplementation"
  | "Governor"
  | "Registry"
  | "SOS"
  | "GnosisSafe"
  | "GnosisSafeProxyFactory";

export type Stack = Record<ContractName, Contract>;

export function asBytes32(str: string) {
  return ethers.utils.formatBytes32String(str);
}

export async function handleRegistry(
  deployer: string,
  deployments: DeploymentsExtension,
  contractName: string,
  deploymentAddress: string
): Promise<void> {
  const { read, execute } = deployments;
  try {
    const isRegistered = await read(
      "Registry",
      {},
      "get",
      asBytes32(contractName)
    );

    if (isRegistered && isRegistered == deploymentAddress) return;
    if (isRegistered && isRegistered != deploymentAddress) {
      await execute(
        "Registry",
        { from: deployer, log: true },
        "update",
        asBytes32(contractName),
        deploymentAddress
      );
      return;
    }
  } catch (_e) {
    await execute(
      "Registry",
      { from: deployer, log: true },
      "register",
      asBytes32(contractName),
      deploymentAddress
    );
  }
}

export function hasRole(contract: Contract, role: string, address: string) {
  return contract.hasRole(
    ethers.utils.keccak256(ethers.utils.toUtf8Bytes(role)),
    address
  );
}

export function grantRole(contract: Contract, role: string, address: string) {
  return contract.grantRole(
    ethers.utils.keccak256(ethers.utils.toUtf8Bytes(role)),
    address
  );
}

export function createFund(
  contract: Contract,
  allowedTokenAddresses: string[],
  underlyingSafeAddress: string,
  name = "Test Fund",
  focus = "Test Focus",
  description = "Test Description Text",
  checks = ["TEST_CHECK_001", "TEST_CHECK_002", "TEST_CHECK_003"].map((check) =>
    ethers.utils.formatBytes32String(check)
  )
) {
  return contract.createFund(
    name,
    focus,
    description,
    underlyingSafeAddress,
    allowedTokenAddresses,
    checks
  );
}

export async function getAddress(
  registry: Contract,
  name: string
): Promise<string> {
  const asBytes32 = ethers.utils.formatBytes32String(name);
  return registry.get(asBytes32);
}

export async function deployContract(
  artifact: string,
  factoryOptions: Signer | FactoryOptions = {},
  constructorParams: unknown[] = []
): Promise<Contract> {
  const factory: ContractFactory = await ethers.getContractFactory(
    artifact,
    factoryOptions
  );

  const contract = constructorParams.length
    ? await factory.deploy(...constructorParams)
    : await factory.deploy();

  return contract.deployed();
}

export async function deployERC20(
  name = "Basic",
  symbol = "BSC",
  initialBalance = ethers.utils.parseUnits("1000000", 18)
): Promise<Contract> {
  return deployContract("contracts/test/BasicERC20.sol:BasicERC20", {}, [
    name,
    symbol,
    initialBalance,
  ]);
}

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

export async function deployRegistry(): Promise<Contract> {
  return deployContract("contracts/Registry.sol:Registry");
}

export async function deployFundManager(
  registry: Contract
): Promise<Contract[]> {
  const implementation = await deployContract("contracts/FundV1.sol:FundV1");

  const manager = await deployContract(
    "contracts/FundManager.sol:FundManager",
    {},
    [registry.address, implementation.address]
  );

  return [manager, implementation];
}

export async function deployDescriptor(): Promise<Contract> {
  return deployContract("NFTDescriptor");
}

export async function deploySOS(
  registry: Contract,
  minter: string
): Promise<Contract> {
  return deployContract("SOS", {}, [registry.address, minter]);
}

export async function deployGovernor(registry: Contract): Promise<Contract> {
  return deployContract("Governor", {}, [registry.address]);
}

export async function deployDonation(registry: Contract): Promise<Contract> {
  return deployContract("Donation", {}, [registry.address]);
}

interface DeploymentOptions {
  governorInitialChecks?: string[];
  SOSMinter?: string;
}

export async function deployStack(
  options: DeploymentOptions = {}
): Promise<Stack> {
  const Registry = await deployRegistry();

  const [FundManager, FundImplementation] = await deployFundManager(Registry);
  const Descriptor = await deployDescriptor();
  const Donation = await deployDonation(Registry);
  const SOS = await deploySOS(Registry, options.SOSMinter || Donation.address);
  const GnosisSafe = await deployGnosisSafe();
  const GnosisSafeProxyFactory = await deployGnosisSafeProxyFactory();

  const checks =
    options.governorInitialChecks ||
    ["TEST_CHECK_001", "TEST_CHECK_002", "TEST_CHECK_003"].map((check) =>
      ethers.utils.formatBytes32String(check)
    );

  const Governor = await deployGovernor(Registry);

  await Registry.register(asBytes32("FUND_MANAGER"), FundManager.address);
  await Registry.register(asBytes32("DONATION"), Donation.address);
  await Registry.register(asBytes32("NFT_DESCRIPTOR"), Descriptor.address);
  await Registry.register(asBytes32("SOS"), SOS.address);
  await Registry.register(asBytes32("GOVERNOR"), Governor.address);

  await Registry.register(
    asBytes32("GNOSIS_SAFE_PROXY_FACTORY"),
    GnosisSafeProxyFactory.address
  );
  await Registry.register(asBytes32("GNOSIS_SAFE"), GnosisSafe.address);

  await grantRole(SOS, "MINTER_ROLE", Donation.address);

  return {
    FundManager,
    FundImplementation,
    Descriptor,
    Donation,
    Governor,
    Registry,
    SOS,
    GnosisSafe,
    GnosisSafeProxyFactory,
  };
}
