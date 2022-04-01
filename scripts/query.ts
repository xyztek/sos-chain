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
      "0xfd3aE3F73714F498B5c31C79D863a39CEb0Ba384"
    );

    // await grantRole(
    //  contract,
    //  "APPROVER_ROLE",
    //"0xEB6BE041000438400816eF46224f4aa17Ca316D7"
    //   "0x1E15c548161F8a1859a8892dd61d102aD33c4829"
    //);

    const approvers = [
      "0x1E15c548161F8a1859a8892dd61d102aD33c4829",
      "0x12b6272E0EA025EEF30d1C8481C85C2c2Ad57421",
      "0xEB6BE041000438400816eF46224f4aa17Ca316D7",
    ];

    for (const approver of approvers) {
      const roleSet = await hasRole(contract, "APPROVER_ROLE", approver);

      console.log(roleSet);
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
