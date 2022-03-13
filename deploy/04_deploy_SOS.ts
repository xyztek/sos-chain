import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { asBytes32 } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, execute, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");
  const Donation = await get("Donation");

  const SVG = await deploy("SVG", {
    from: deployer,
    args: [],
    log: true,
  });

  const NFTDescriptor = await deploy("NFTDescriptor", {
    from: deployer,
    args: [],
    libraries: {
      SVG: SVG.address,
    },
    log: true,
  });

  await execute(
    "Registry",
    { from: deployer, log: true },
    "register",
    asBytes32("NFT_DESCRIPTOR"),
    NFTDescriptor.address
  );

  const SOS = await deploy("SOS", {
    from: deployer,
    args: [Registry.address, Donation.address],
    log: true,
  });

  await execute(
    "Registry",
    { from: deployer, log: true },
    "register",
    asBytes32("SOS"),
    SOS.address
  );
};

export default func;

func.tags = ["SOS"];
