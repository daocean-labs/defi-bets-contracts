import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  networkConfig,
  getNetworkIdFromName,
  developmentChains,
} from "../helper-hardhat-config";
import { verify } from "../helper-functions";

const deployPriceOracle: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployer } = await hre.getNamedAccounts();

  const { deploy } = hre.deployments;

  const network = hre.network.name;

  const chainId = await getNetworkIdFromName(network);

  if (chainId) {
    const version = 1;
    const underlying = "BTC";
    const description = "Price Oracle";

    const decimals = networkConfig[chainId].decimalsPriceFeed;

    const args = [decimals, description, version, underlying];

    const priceOracle = await deploy("BTCPriceOracle", {
      from: deployer,
      args: args,
      log: true,
      autoMine: true,
      waitConfirmations: networkConfig[chainId].confirmations,
    });
    if (!developmentChains.includes(hre.network.name)) {
      await verify(priceOracle.address, args);
    }
  } else {
    console.log("Missing parameters in hardhat helper config...");
  }
};

deployPriceOracle.tags = ["all", "oracle", "price-oracle"];

export default deployPriceOracle;
