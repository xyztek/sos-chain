import { BytesLike, ethers } from "ethers";
import * as dotenv from "dotenv";

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
  const deployNames = argv();
  deployNames == null && console.log("Warning no file given");
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

const test = async () => {
  const provider = new ethers.providers.InfuraProvider("rinkeby", {
    projectId: process.env.INFURA_ID,
  }); // local

  const signer = new ethers.Wallet(
    process.env.PRIVATE_KEY as BytesLike,
    provider
  );
};
