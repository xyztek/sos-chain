import { BytesLike, Contract, ethers, Wallet } from "ethers";

import * as GnosisSafeABI from "../artifacts/@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol/GnosisSafe.json";
import * as FundManagerABI from "../artifacts/contracts/FundManager.sol/FundManager.json";

import * as dotenv from "dotenv";
dotenv.config();

async function main() {
  const provider = new ethers.providers.JsonRpcProvider();

  const signer = new ethers.Wallet(
    process.env.PRIVATE_KEY as BytesLike,
    provider
  );

  const FundManager = new Contract(
    "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
    FundManagerABI.abi,
    signer
  );

  console.log(
    await FundManager.encodeSetup(
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
      1,
      "0x0000000000000000000000000000000000000000",
      "0x",
      "0x0000000000000000000000000000000000000000",
      "0x0000000000000000000000000000000000000000",
      0,
      "0x0000000000000000000000000000000000000000"
    )
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
