import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { asBytes32 } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, execute, get } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const defaultChecks = [
    "TEST_CHECK_001",
    "TEST_CHECK_002",
    "TEST_CHECK_003",
  ].map((check) => asBytes32(check));

  const Governor = await deploy("Governor", {
    from: deployer,
    args: [Registry.address, defaultChecks],
    log: true,
  });

  await execute(
    "Registry",
    { from: deployer, log: true },
    "register",
    asBytes32("GOVERNOR"),
    Governor.address
  );
};

export default func;

func.tags = ["Governor"];
