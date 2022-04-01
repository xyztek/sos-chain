import { HardhatRuntimeEnvironment } from "hardhat/types";

import { DeployFunction } from "hardhat-deploy/types";
import * as LinkTokenJSON from "../artifacts/@chainlink/contracts/src/v0.4/LinkToken.sol/LinkToken.json";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;

  const { deploy, save } = deployments;

  if (hre.network.name != "hardhat" && hre.network.name != "localhost") {
    save("ChainLinkToken", {
      abi: LinkTokenJSON.abi,
      address: Networks[hre.network.name],
    });
    return;
  }

  const { deployer } = await getNamedAccounts();

  await deploy("ChainLinkToken", {
    contract: "contracts/mock/mockChainLinkToken.sol:MockLinkToken",
    from: deployer,
    args: [],
    log: true,
  });
};

const Networks: { [key: string]: string } = {
  fuji: "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
  rinkeby: "0x01BE23585060835E02B77ef475b0Cc51aA1e0709",
  mainnet: "0x514910771AF9Ca656af840dff83E8264EcF986CA",
  avalanche: "0x5947BB275c521040051D82396192181b413227A3",
};
export default func;

func.tags = ["ChainLinkToken"];
