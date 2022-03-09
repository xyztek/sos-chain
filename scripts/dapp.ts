import { ethers } from "ethers";
import * as NFTJson from "../artifacts/contracts/NFTDescriptor.sol/NFTDescriptor.json";

async function main() {
  const provider = new ethers.providers.JsonRpcProvider();

  const abi = NFTJson.abi;
  const contract = new ethers.Contract(
    "0x7a2088a1bFc9d81c55368AE168C2C02570cB814F",
    abi,
    provider
  );

  const p = [
    1,
    "0xc5e104655052a96C2bc6A538612FE2a87b6AF655",
    "SOS",
    4,
    true,
    "0xc5e104655052a96C2bc6A538612FE2a87b6AF655",
    "UNICEF",
    "Forest Fire",
  ];
  const response = await contract.constructTokenURI(p);
  console.log(response);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
