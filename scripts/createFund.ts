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
        name: "UNICEF - Save the Children",
        focus: "War",
        description: `UNICEF is working around the clock to scale up life-saving programmes for children. This includes:
- Ramping up efforts to meet critical and escalating needs for safe water, health care, education and protection.
- Delivering midwifery, obstetrics, surgical medical kits, first aid kits and diagnostic and treatment equipment to temporary storage facilities.
- Delivering family hygiene kits, baby diapers, maternal health kits, institutional hygiene kits, disinfectants and bottled water to health and social institutions.
- Working with municipalities to ensure that there is immediate help for children and families in need.
- Supporting mobile teams providing child protection services and psychosocial care to children traumatized by the chronic insecurity.
- Setting up Blue Dot hubs in partnership with UNHCR and local authorities, to provide critical support and protection services for children and families. 
- Continuing emergency response efforts to address the COVID-19 outbreak, including by working with municipalities to increase COVID-19 vaccination rates, and by strengthening awareness-raising and capacity-building efforts.`,
      },
    ];

    for (const fund of funds) {
      await fundManager.createFund(
        fund.name,
        fund.focus,
        fund.description,
        [USDC[hre.network.name]],
        SAFE[hre.network.name]
      );
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
