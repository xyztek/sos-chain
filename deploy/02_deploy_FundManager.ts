import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import {
  deployERC20,
  fundManagerDataCreator,
  handleRegistry,
} from "../scripts/helpers";

const SHOULD_DEPLOY_ERC20 = ["hardhat", "localhost", "fuji"];
const SHOULD_SETUP_FUND = ["hardhat", "localhost", "fuji"];

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

  if (SHOULD_DEPLOY_ERC20.includes(hre.network.name)) {
    const USDC = await deploy("BasicERC20", {
      from: deployer,
      args: ["USD Coin", "USDC", ethers.utils.parseUnits("10000000", 18)],
    });

    console.log(
      "\n\n",
      `Deployed fake USDC ERC20 Contract at: ${USDC.address}`,
      "\n\n"
    );

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
