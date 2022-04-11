import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { handleRegistry } from "../scripts/helpers";
import { DeployResult } from "hardhat-deploy/dist/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, get } = deployments;

  const { deployer } = await getNamedAccounts();
  let OracleConsumer: DeployResult;
  const ChainLinkToken = await get("ChainLinkToken");
  const Registry = await get("Registry");

  const OracleArgcis = await get("OracleArgcis");
  const Governor = await get("Governor");

  if (hre.network.name != "hardhat" && hre.network.name != "localhost") {
    OracleConsumer = await deploy("OracleConsumer", {
      contract: "OracleConsumer",
      from: deployer,
      args: [
        OracleArgcis.address,
        Registry.address,
        ChainLinkToken.address,
        Governor.address,
      ],
      log: true,
    });
  } else {
    OracleConsumer = await deploy("OracleConsumer", {
      contract: "contracts/mock/mockOracleConsumer.sol:MockOracleConsumer",
      from: deployer,
      args: [OracleArgcis.address, ChainLinkToken.address],
      log: true,
    });
  }

  await handleRegistry(
    deployer,
    deployments,
    "ORACLE_CONSUMER",
    OracleConsumer.address
  );
};

export default func;

func.tags = ["OracleConsumer"];
