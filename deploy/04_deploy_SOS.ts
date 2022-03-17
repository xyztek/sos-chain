import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { handleRegistry } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");
  const Donation = await get("Donation");

  const NFTDescriptor = await deploy("NFTDescriptor", {
    from: deployer,
    args: [],
    log: true,
  });

  await handleRegistry(
    deployer,
    deployments,
    "NFT_DESCRIPTOR",
    NFTDescriptor.address
  );

  const SOS = await deploy("SOS", {
    from: deployer,
    args: [Registry.address, Donation.address],
    log: true,
  });

  await handleRegistry(deployer, deployments, "SOS", SOS.address);
};

export default func;

func.tags = ["SOS"];
