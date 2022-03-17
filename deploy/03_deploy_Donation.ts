import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { handleRegistry } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const Donation = await deploy("Donation", {
    from: deployer,
    args: [Registry.address],
    log: true,
  });

  await handleRegistry(deployer, deployments, "DONATION", Donation.address);
};

export default func;

func.tags = ["Donation"];
