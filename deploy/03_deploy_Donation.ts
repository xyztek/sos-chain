import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { asBytes32 } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, execute, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const Donation = await deploy("Donation", {
    from: deployer,
    args: [Registry.address],
    log: true,
  });

  await execute(
    "Registry",
    { from: deployer, log: true },
    "register",
    asBytes32("DONATION"),
    Donation.address
  );
};

export default func;

func.tags = ["Donation"];
