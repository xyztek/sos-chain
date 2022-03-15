import { BytesLike, ethers } from "ethers";
import * as dotenv from "dotenv";

import * as apiConsumer from "../artifacts/contracts/hybrid/APIConsumer.sol/APIConsumer.json";

dotenv.config();

async function main() {
  const provider = new ethers.providers.InfuraProvider("rinkeby", {
    projectId: process.env.INFURA_ID,
  }); // local

  const signer = new ethers.Wallet(
    process.env.PRIVATE_KEY as BytesLike,
    provider
  );

  const abi = apiConsumer.abi;
  const contract = new ethers.Contract(
    "0x8d365Cb09b1be792fB1A4654DF0990464A0A8BAF",
    abi,
    signer
  );

  const response = await contract.requestVolumeData({ gasLimit: 100000 });
  console.log(response);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
