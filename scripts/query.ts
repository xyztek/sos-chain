// FundManager deployed at 0xC0E04b36F13EFFDc5e9A68d89A692C75544aa599
// FundImplementation deployed at 0x93511aB052B4f14f34001454ecB9AaCd5c178F57
// Descriptor deployed at 0xcE1E1Bf5Df4713eDA158670515a6B04C4b3916Ff
// Donation deployed at 0x2e0f7118300AFC8f7d205DadF14006ccEb52D1DE
// Governor deployed at 0x43ac22032AaA4834C4b9701083C88CC8c84F92d4
// Registry deployed at 0xC9e3f758cc997F89F058fa83032F49A1ec64e727
// SOS deployed at 0x92c682Bc643040083D6d837f836243003cBe44AB
// Fake USDC deployed at 0xa0E3d8DA862Def4fa99db07F72C7a2a4Ce26bec2

import { Contract, ContractFactory } from "ethers";
import { ethers } from "hardhat";

async function main() {
  try {
    const [owner, EOA1, _EOA2] = await ethers.getSigners();

    const factory: ContractFactory = await ethers.getContractFactory(
      "FundManager"
    );

    const contract = factory.attach(
      "0xC0E04b36F13EFFDc5e9A68d89A692C75544aa599"
    );

    const events = await contract.getFundAddress(0);

    console.log(events);
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
