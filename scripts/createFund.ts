import { Contract } from "ethers";
import hre, { ethers } from "hardhat";

import { asBytes32 } from "./helpers";

async function main() {
  try {
    const [_owner, _EOA1, _EOA2] = await ethers.getSigners();

    const { getNamedAccounts } = hre;
    const { safe } = await getNamedAccounts();

    const registry: Contract = (
      await ethers.getContractFactory("Registry")
    ).attach("0x9543127f4483364200aA99b6C10B8c8C9Ce364Cb");

    const fundManagerAddress = await registry.get(asBytes32("FUND_MANAGER"));

    const fundManager: Contract = (
      await ethers.getContractFactory("FundManager")
    ).attach(fundManagerAddress);

    const USDC: Record<string, string> = {
      rinkeby: "0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b",
      localhost: "",
    };

    const SAFE: Record<string, string> = {
      rinkeby: "0xF35164F058F1b85E277C306dc743ab82b94212dC",
      localhost: safe,
    };

    const funds = [
      {
        name: "",
        focus: "",
        description: "",
      },
    ];

    console.log(hre.config, hre.network);

    for (const fund of funds) {
      /*
      await fundManager.createFund(
        fund.name,
        fund.focus,
        fund.description,
        [USDC[hre.network.name]],
        SAFE[hre.network.name]
      );
      */
    }
  } catch (error) {
    console.log(error);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
