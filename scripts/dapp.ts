import hre, { ethers } from "hardhat";
import { asBytes32 } from "./helpers";
import { BytesLike, Contract } from "ethers";
import * as dotenv from "dotenv";
import { formatBytes32String } from "ethers/lib/utils";

dotenv.config();

const process = require("process");

const argv = () => {
  const values = [];
  for (const key of process.argv) {
    const value: string = key.startsWith("--") ? key.replace("--", "") : null;
    value != null && values.push(value);
  }

  return values.length > 0 ? values : null;
};

async function main() {
  const REGISTRY_ADDRESSES = "0x3262A1f3948c171725B254e2ff69aE40904F5a37";
  const fundAdd = "0x99181264252aB558eC7D7754868411AE67f4469F";

  const registry: Contract = (
    await ethers.getContractFactory("Registry")
  ).attach(REGISTRY_ADDRESSES);

  const fund: Contract = (await ethers.getContractFactory("FundV1")).attach(
    fundAdd
  );
  const oracleArgcis = await registry.get(asBytes32("SOS_ORACLE"));

  const governer: Contract = (
    await ethers.getContractFactory("Governor")
  ).attach(await registry.get(asBytes32("GOVERNOR")));

  /*   const oracleArgcis: Contract = (
    await ethers.getContractFactory("OracleArgcis")
  ).attach(await registry.get(asBytes32("SOS_ORACLE")));

  await oracleArgcis.setFulfillmentPermission(
    "0xDC67B2eb21C480d019abEC4b53ac012eAFF1b328",
    true
  ); */
  /*   await fund.grantRole(
    ethers.utils.keccak256(ethers.utils.toUtf8Bytes("APPROVER_ROLE")),
    "0x19DB128f0E2f04b185e72Aabdd3664D0217210c6"
  ); */
  await governer.callOracle(0, 0);
  // 3 , 0

  /*   console.log(
    await fund.hasRole(
      ethers.utils.keccak256(ethers.utils.toUtf8Bytes("APPROVER_ROLE")),
      "0x19DB128f0E2f04b185e72Aabdd3664D0217210c6"
    )
  ); */
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
