import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";

import "@openzeppelin/hardhat-upgrades";

import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";

import "hardhat-gas-reporter";

import "hardhat-deploy";
// import "hardhat-deploy-ethers";

// import "solidity-coverage";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (_taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const gasPriceConfiguration = {
  ethereum: {
    token: "ETH",
    api: "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
  },
  polygon: {
    token: "MATIC",
    api: "https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice",
  },
  avalanche: {
    token: "AVAX",
    api: "https://api.snowtrace.io/api?module=proxy&action=eth_gasPrice",
  },
  fantom: {
    token: "FTM",
    api: "https://api.ftmscan.io/api?module=proxy&action=eth_gasPrice",
  },
};

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const TARGET_NETWORK = "avalanche";

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  solidity: {
    version: "0.8.10",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  namedAccounts: {
    deployer: 0,
    safe: 9,
  },
  networks: {
    fuji: {
      url: `https://speedy-nodes-nyc.moralis.io/20bb3a98759a92194f0b3e8a/avalanche/testnet`,
      accounts: [`${process.env.RINKEBY_PRIVATE_KEY}`],
    },
    rinkeby: {
      url: `https://speedy-nodes-nyc.moralis.io/20bb3a98759a92194f0b3e8a/eth/rinkeby`,
      accounts: [`${process.env.RINKEBY_PRIVATE_KEY}`],
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    rinkbery: {
      url: process.env.RINKBERY_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },

    hardhat: {
      throwOnTransactionFailures: true,
      throwOnCallFailures: true,
      allowUnlimitedContractSize: false,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    coinmarketcap: process.env.COINMARKETCAP_APIKEY,
    gasPriceApi: gasPriceConfiguration[TARGET_NETWORK].api,
    token: gasPriceConfiguration[TARGET_NETWORK].token,
    currency: "USD",
    excludeContracts: ["BasicToken", "BasicERC20", "ERC20", "ERC721"],
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
