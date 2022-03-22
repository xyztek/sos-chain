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
    args: [Registry.address],
    log: true,
  });

  await handleRegistry(deployer, deployments, "GOVERNOR", Governor.address);

  const approvers = [
    "0x1E15c548161F8a1859a8892dd61d102aD33c4829",
    "0x12b6272E0EA025EEF30d1C8481C85C2c2Ad57421",
    "0xEB6BE041000438400816eF46224f4aa17Ca316D7",
  ];

  for (const approver of approvers) {
    await execute(
      "Governor",
      { from: deployer, log: true },
      "grantRole",
      ethers.utils.keccak256(ethers.utils.toUtf8Bytes("APPROVER_ROLE")),
      approver
    );
  }
};

export default func;

func.tags = ["Governor"];
