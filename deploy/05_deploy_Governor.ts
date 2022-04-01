import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ethers } from "ethers";

import { DeployFunction } from "hardhat-deploy/types";

import { handleRegistry } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const Governor = await deploy("Governor", {
    from: deployer,
    args: [Registry.address],
    log: true,
  });

  await handleRegistry(deployer, deployments, "GOVERNOR", Governor.address);
};

export default func;

func.tags = ["Governor"];
