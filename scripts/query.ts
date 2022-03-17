import { ContractFactory } from "ethers";
import { ethers } from "hardhat";

import { grantRole } from "./helpers";

async function main() {
  try {
    const [_owner, _EOA1, _EOA2] = await ethers.getSigners();

    const factory: ContractFactory = await ethers.getContractFactory(
      "Governor"
    );

    const contract = factory.attach(
      "0xF7a81Feb465f25b418f678180084ce4C3652a869"
    );

    await grantRole(
      contract,
      "APPROVER_ROLE",
      "0xEB6BE041000438400816eF46224f4aa17Ca316D7"
    );
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
