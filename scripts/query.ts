import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";

async function main() {
  try {
    const [owner, EOA1, _EOA2] = await ethers.getSigners();

    const factory: ContractFactory = await ethers.getContractFactory(
      "FundManager"
    );

    const contract = factory.attach(
      "0x1e09936F01A9A56fC208fF55dbc7969C5C04B711"
    );

    const fundV1Address = await contract.getFundAddress(1);

    const fundFactory: ContractFactory = await ethers.getContractFactory(
      "FundV1"
    );

    const fund = fundFactory.attach(fundV1Address);

    await fund.addToken("0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b");
    await fund.removeToken("0x8967CddA31Dc3f971276dc4B534eC7a2a3e1fA81");

    console.log(await fund.getAllowedTokens());
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
