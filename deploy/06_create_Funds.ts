import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { ethers } from "ethers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, execute } = deployments;

  const { deployer, safe } = await getNamedAccounts();

  const ERC20 = await deploy("BasicERC20", {
    from: deployer,
    args: ["USD Coin", "USDC", ethers.BigNumber.from(1000000)],
    log: true,
  });

  await execute(
    "FundManager",
    { from: deployer, log: true },
    "createFund",
    "Fund 001",
    "Focus A",
    "Description Text",
    [ERC20.address],
    hre.network.name == "rinkeby"
      ? "0xF35164F058F1b85E277C306dc743ab82b94212dC"
      : safe
  );

  await execute(
    "FundManager",
    { from: deployer, log: true },
    "createFund",
    "Fund 002",
    "Focus B",
    "Description Text",
    [ERC20.address],
    hre.network.name == "rinkeby"
      ? "0xF35164F058F1b85E277C306dc743ab82b94212dC"
      : safe
  );
};

export default func;

const skips = ["localhost", "rinkeby"];

func.skip = (hre: HardhatRuntimeEnvironment) => {
  return Promise.resolve(!skips.find((network) => network == hre.network.name));
};

func.tags = ["CreateFunds"];
