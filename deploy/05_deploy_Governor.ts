import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ethers } from "ethers";

import { DeployFunction } from "hardhat-deploy/types";

import { asBytes32, handleRegistry } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, execute, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const defaultChecks = [
    "VERIFY RECIPIENT",
    "VERIFY RECIPIENT ADDRESS",
    "VERIFY LOCATION",
  ].map((check) => asBytes32(check));

  const Governor = await deploy("Governor", {
    from: deployer,
    args: [Registry.address, defaultChecks],
    log: true,
  });

  await handleRegistry(deployer, deployments, "GOVERNOR", Governor.address);

  await execute(
    "Governor",
    { from: deployer, log: true },
    "grantRole",
    ethers.utils.keccak256(ethers.utils.toUtf8Bytes("APPROVER_ROLE")),
    "0xEB6BE041000438400816eF46224f4aa17Ca316D7"
  );
};

export default func;

func.tags = ["Governor"];
