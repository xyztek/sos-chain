import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { handleRegistry, setFulfillmentPermission } from "../scripts/helpers";

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
    "SOS_ORACLE",
    OracleArgcis.address
  );
};

export default func;

const Networks: { [key: string]: string } = {
  fuji: "0xDC67B2eb21C480d019abEC4b53ac012eAFF1b328",
};

func.tags = ["OracleArgcis"];
