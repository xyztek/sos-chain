import { ContractFactory, Contract, Signer } from "ethers";
import { ethers } from "hardhat";
import { FactoryOptions } from "hardhat/types";

export type ContractName =
  | "Descriptor"
  | "Donation"
  | "FundManager"
  | "FundImplementation"
  | "Governor"
  | "Registry"
  | "SOS";

export type Stack = Record<ContractName, Contract>;

export function asBytes32(str: string) {
  return ethers.utils.formatBytes32String(str);
}

export function grantRole(contract: Contract, role: string, address: string) {
  return contract.grantRole(
    ethers.utils.keccak256(ethers.utils.toUtf8Bytes(role)),
    address
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
  initialBalance = ethers.BigNumber.from(1000000)
): Promise<Contract> {
  return deployContract("contracts/test/BasicERC20.sol:BasicERC20", {}, [
    name,
    symbol,
    initialBalance,
  ]);
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
  const svg = await deployContract("SVG");

  return deployContract("NFTDescriptor", {
    libraries: {
      SVG: svg.address,
    },
  });
}

export async function deploySOS(
  registry: Contract,
  minter: string
): Promise<Contract> {
  return deployContract("SOS", {}, [registry.address, minter]);
}

export async function deployGovernor(
  registry: Contract,
  initialChecks: string[]
): Promise<Contract> {
  return deployContract("Governor", {}, [registry.address, initialChecks]);
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

  const checks =
    options.governorInitialChecks ||
    ["TEST_CHECK_001", "TEST_CHECK_002", "TEST_CHECK_003"].map((check) =>
      ethers.utils.formatBytes32String(check)
    );

  const Governor = await deployGovernor(Registry, checks);

  await Registry.register(asBytes32("FUND_MANAGER"), FundManager.address);
  await Registry.register(asBytes32("DONATION"), Donation.address);
  await Registry.register(asBytes32("NFT_DESCRIPTOR"), Descriptor.address);
  await Registry.register(asBytes32("SOS"), SOS.address);
  await Registry.register(asBytes32("GOVERNOR"), Governor.address);

  return {
    FundManager,
    FundImplementation,
    Descriptor,
    Donation,
    Governor,
    Registry,
    SOS,
  };
}