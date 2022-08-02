import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import {
  deployERC20,
  fundManagerDataCreator,
  handleRegistry,
} from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, ethers } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const implementation = await deploy("FundV1", {
    from: deployer,
    args: [],
    log: true,
  });

  const FundManager = await deploy("FundManagerV1", {
    from: deployer,
    args: [],
    log: true,
    proxy: {
      owner: deployer,
      proxyContract: "FundManager",
      execute: {
        methodName: "initialize",
        args: [
          fundManagerDataCreator(Registry.address, implementation.address),
        ],
      },
    },
  });

  if (hre.network.name === "localhost" || hre.network.name === "hardhat") {
    const USDC = await deployERC20("USD Coin", "USDC");
    console.log(`Deployed fake USDC ERC20 Contract at ${USDC.address}..`);
  }

  await handleRegistry(
    deployer,
    deployments,
    "FUND_MANAGER",
    FundManager.address
  );
};

export default func;

func.tags = ["FundManager"];
