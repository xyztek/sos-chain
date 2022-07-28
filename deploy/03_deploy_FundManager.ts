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

  const Donation = await get("Donation");

  const implementation = await deploy("FundV1", {
    from: deployer,
    args: [Donation.address],
    log: true,
  });

  // const FundManagerV1 = await deploy("FundManagerV1", {
  //   from: deployer,
  //   args: [],
  //   log: true,
  // });
  // const factory = await ethers.getContractAt("FundManagerV1", FundManagerV1.address);
  // await factory.deployed();
  // await FundManagerV1.deployed();
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

  const USDC = await deployERC20("USD Coin", "USDC");

  await handleRegistry(
    deployer,
    deployments,
    "FUND_MANAGER",
    FundManager.address
  );
};

export default func;

func.tags = ["FundManager"];
