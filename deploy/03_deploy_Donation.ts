import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";

import { handleRegistry, hasRole } from "../scripts/helpers";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, ethers, getNamedAccounts } = hre;

  const { deploy, get, execute } = deployments;

  const { deployer } = await getNamedAccounts();

  const Registry = await get("Registry");

  const DonationStorage = await deploy("DonationStorage", {
    from: deployer,
    args: [Registry.address],
    log: true,
  });

  const Donation = await deploy("Donation", {
    from: deployer,
    args: [Registry.address, DonationStorage.address],
    log: true,
  });

  await execute(
    "DonationStorage",
    { from: deployer, log: true },
    "grantRole",
    ethers.utils.keccak256(ethers.utils.toUtf8Bytes("STORE_ROLE")),
    Donation.address
  );

  await execute(
    "FundManagerV1",
    { from: deployer, log: true },
    "grantRole",
    ethers.utils.keccak256(ethers.utils.toUtf8Bytes("DONATION_ROLE")),
    Donation.address
  );

  await handleRegistry(
    deployer,
    deployments,
    "DONATION_STORAGE",
    DonationStorage.address
  );

  await handleRegistry(deployer, deployments, "DONATION", Donation.address);
};

export default func;

func.tags = ["Donation"];
