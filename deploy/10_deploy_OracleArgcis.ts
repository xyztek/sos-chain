import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { handleRegistry } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const ChainLinkToken = await get("ChainLinkToken");

  const OracleArgcis = await deploy("OracleArgcis", {
    from: deployer,
    args: [ChainLinkToken.address],
    log: true,
  });

  await handleRegistry(
    deployer,
    deployments,
    "OracleArgcis",
    OracleArgcis.address
  );
};

export default func;

func.tags = ["OracleArgcis"];
