import { ContractFactory } from "ethers";
import { ethers } from "hardhat";

import { hasRole, grantRole } from "./helpers";

async function main() {
  try {
    const [_owner, _EOA1, _EOA2] = await ethers.getSigners();

    const factory: ContractFactory = await ethers.getContractFactory(
      "Governor"
    );

    const contract = factory.attach(
      "0x740FEcA0d7f81c08467eA265ABcDb4959c81006A"
    );

    // await grantRole(
    //  contract,
    //  "APPROVER_ROLE",
    //"0xEB6BE041000438400816eF46224f4aa17Ca316D7"
    //   "0x1E15c548161F8a1859a8892dd61d102aD33c4829"
    //);

    const roleSet = await hasRole(
      contract,
      "APPROVER_ROLE",
      //"0xEB6BE041000438400816eF46224f4aa17Ca316D7"
      "0x1E15c548161F8a1859a8892dd61d102aD33c4829"
    );

    console.log(roleSet);
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
