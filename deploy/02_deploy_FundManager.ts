import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { asBytes32 } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, execute, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const implementation = await deploy("FundV1", {
    from: deployer,
    args: [],
    log: true,
  });

  const FundManager = await deploy("FundManager", {
    from: deployer,
    args: [Registry.address, implementation.address],
    log: true,
  });

  await execute(
    "Registry",
    { from: deployer, log: true },
    "register",
    asBytes32("FUND_MANAGER"),
    FundManager.address
  );
};

export default func;

func.tags = ["FundManager"];
