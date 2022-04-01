import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";
import { handleRegistry } from "../scripts/helpers";

import * as GnosisSafeJSON from "../artifacts/@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol/GnosisSafe.json";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, save } = deployments;

  const { deployer } = await getNamedAccounts();

  let address: string;

  if (hre.network.name != "hardhat" && hre.network.name != "localhost") {
    address = Networks[hre.network.name];
    save("GnosisSafe", {
      abi: GnosisSafeJSON.abi,
      address,
    });
  } else {
    const GnosisSafeProxy = await deploy("GnosisSafe", {
      from: deployer,
      args: [],
      log: true,
    });
    address = GnosisSafeProxy.address;
  }

  await handleRegistry(deployer, deployments, "GNOSIS_SAFE", address);
};

// check address for this and proxy

const Networks: { [key: string]: string } = {
  rinkeby: "0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552",
  mainnet: "0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552",
  avalanche: "0x69f4D1788e39c87893C980c06EdF4b7f686e2938",
  fuji: "0x1666fEb9f1A14C40292454CA162D0799E0bcE273",
};

export default func;

func.tags = ["GnosisSafe"];
