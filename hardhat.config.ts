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

const gasPriceTargetNetwork = "avalanche";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.6.6",
        settings: {},
      },
      {
        version: "0.4.24",
        settings: {},
      },
      {
        version: "0.8.10",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  namedAccounts: {
    deployer: 0,
    safe: 9,
  },
  networks: {
    ethereum: {
      url: process.env.ETHEREUM_NODE,
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
    },
    fuji: {
      url: process.env.FUJI_NODE,
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
    },
    avalanche: {
      url: process.env.AVALANCHE_NODE,
      accounts: {
        mnemonic: process.env.MNEMONIC,
      },
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
    gasPriceApi: gasPriceConfiguration[gasPriceTargetNetwork].api,
    token: gasPriceConfiguration[gasPriceTargetNetwork].token,
    currency: "USD",
    excludeContracts: ["BasicToken", "BasicERC20", "ERC20", "ERC721"],
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
