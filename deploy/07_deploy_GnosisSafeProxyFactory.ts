import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";
import { handleRegistry } from "../scripts/helpers";

import * as GnosisSafeProxyJSON from "../artifacts/@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol/GnosisSafeProxyFactory.json";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, save } = deployments;

  const { deployer } = await getNamedAccounts();

  let address: string;

  if (hre.network.name != "hardhat" && hre.network.name != "localhost") {
    address = Networks[hre.network.name];
    save("GnosisSafeProxyFactory", {
      abi: GnosisSafeProxyJSON.abi,
      address,
    });
  } else {
    const GnosisSafeProxy = await deploy("GnosisSafeProxyFactory", {
      from: deployer,
      args: [],
      log: true,
    });
    address = GnosisSafeProxy.address;
  }

  await handleRegistry(
    deployer,
    deployments,
    "GnosisSafeProxyFactory",
    address
  );
};

// check address for this and proxy

const Networks: { [key: string]: string } = {
  rinkeby: "0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",
  mainnet: "0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2",
  avalanche: "0xC22834581EbC8527d974F8a1c97E1bEA4EF910BC",
  fuji: "0x6ed86d9334c5ecba9D8B78a8bc0aAc7E965c6b2a",
};

export default func;

func.tags = ["GnosisSafeProxyFactory"];
