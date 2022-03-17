import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { ethers } from "ethers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, execute, read } = deployments;

  const { deployer, safe } = await getNamedAccounts();

  const USDC: Record<string, string> = {
    rinkeby: "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b",
    localhost: "",
  };

  const SAFE: Record<string, string> = {
    rinkeby: "0xF35164F058F1b85E277C306dc743ab82b94212dC",
    localhost: safe,
  };

  if (hre.network.name == "localhost") {
    const ERC20 = await deploy("BasicERC20", {
      from: deployer,
      args: ["USD Coin", "USDC", ethers.utils.parseUnits("1000000000", 18)],
      log: true,
    });

    USDC.localhost = ERC20.address;
  }

  const funds = [
    [
      "SOS Wildfires Fund",
      "Natural Disaster",
      "SOS Wildfires Fund is a contribution raised to reduce the causes of wildfires, compensate their effects and carry out relevant field missions to take precautions.",
    ],
  ];

  const existing = await read("FundManager", {}, "getFunds");

  if (!existing.length) {
    for (const [name, focus, description] of funds) {
      await execute(
        "FundManager",
        { from: deployer, log: true },
        "createFund",
        name,
        focus,
        description,
        [USDC[hre.network.name]],
        SAFE[hre.network.name]
      );
    }
  }
};

export default func;

const skips = ["localhost", "rinkeby"];

func.skip = (hre: HardhatRuntimeEnvironment) => {
  return Promise.resolve(!skips.find((network) => network == hre.network.name));
};

func.tags = ["CreateFunds"];
