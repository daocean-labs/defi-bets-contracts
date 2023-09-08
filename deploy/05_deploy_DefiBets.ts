import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  networkConfig,
  getNetworkIdFromName,
  developmentChains,
} from "../helper-hardhat-config";
import { verify } from "../helper-functions";

const deployDefiBets: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployer } = await hre.getNamedAccounts();

  const { deploy, get } = hre.deployments;

  const network = hre.network.name;

  const chainId = await getNetworkIdFromName(network);

  if (chainId) {
    const managerContractAddress = (await get("DefiBetsManager")).address;
    const delta = networkConfig[chainId].timeDelta;
    const args = ["BTC", managerContractAddress, delta];

    const bets = await deploy("DefiBets", {
      from: deployer,
      log: true,
      args: args,
      autoMine: true,
      waitConfirmations: networkConfig[chainId].confirmations,
    });

    if (!developmentChains.includes(hre.network.name)) {
      await verify(bets.address, args);
    }
  }
};

deployDefiBets.tags = ["all", "game", "bet"];

export default deployDefiBets;
