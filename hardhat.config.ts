import * as dotenv from "dotenv";
dotenv.config();
import fs from "fs";
import "@nomicfoundation/hardhat-toolbox";
import "@typechain/hardhat";
import "hardhat-preprocessor";
import "hardhat-deploy";
import { HardhatUserConfig } from "hardhat/config";

import "./tasks/set-price";
import "./tasks/start-season";
import "./tasks/activate-account";
import "./tasks/set-vola";
import "./tasks/init-exp-times";

function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean)
    .map((line) => line.trim().split("="));
}

const providerApiKey =
  process.env.ALCHEMY_API_KEY || "oKxs-03sij-U_N0iOlrSsZFr29-IqbuF";
// If not set, it uses the hardhat account 0 private key.
const deployerPrivateKey =
  process.env.DEPLOYER_PRIVATE_KEY ??
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    // View the networks that are pre-configured.
    // If the network you are looking for is not here you can add new network settings

    dmcTestnet: {
      url: "https://testnet-dmc.mydefichain.com:20551/",
      //url: "https://changi.dfi.team/",
      // url: "http://127.0.0.1:20551/",
      accounts: [deployerPrivateKey],
      chainId: 1133,
      gas: 30_000_000,
    },
  },
  namedAccounts: {
    deployer: {
      // By default, it will take the first Hardhat account as the deployer
      default: 0,
    },
  },
  etherscan: {
    apiKey: {
      dmcTestnet: " ",
    },
    customChains: [
      {
        network: "dmcTestnet",
        chainId: 1133,
        urls: {
          apiURL: "https://testnet-dmc.mydefichain.com:8444/api",
          browserURL: "https://testnet-dmc.mydefichain.com:8444/",
        },
      },
    ],
  },
  paths: {
    sources: "./src", // Use ./src rather than ./contracts as Hardhat expects
    cache: "./cache_hardhat", // Use a different cache for Hardhat than Foundry
    deployments: "deployments",
  },
  // This fully resolves paths for imports in the ./lib directory for Hardhat
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          getRemappings().forEach(([find, replace]) => {
            if (line.match(find)) {
              line = line.replace(find, replace);
            }
          });
        }
        return line;
      },
    }),
  },
};

export default config;
