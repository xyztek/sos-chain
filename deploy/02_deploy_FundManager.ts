import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import {
  fundManagerDataCreator,
  handleRegistry,
} from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const implementationFund = await deploy("FundV1", {
    from: deployer,
    args: [],
    log: true,
  });

  const implementationFundManager = await deploy("FundManagerV1", {
    from: deployer,
    args: [Registry.address, implementationFund.address], // empty ?
    log: true,
  });

  const FundManager = await deploy("FundManager", {
    from: deployer,
    args: [
      implementationFundManager.address,
      fundManagerDataCreator(Registry.address, implementationFund.address),
    ],
    log: true,
  });

  await handleRegistry(
    deployer,
    deployments,
    "FUND_MANAGERV1",
    implementationFundManager.address
  );
};

export default func;

func.tags = ["FundManager"];
