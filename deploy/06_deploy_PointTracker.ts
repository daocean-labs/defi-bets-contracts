import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  networkConfig,
  getNetworkIdFromName,
  developmentChains,
} from "../helper-hardhat-config";
import { verify } from "../helper-functions";

const deployPointTracker: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployer } = await hre.getNamedAccounts();

  const { deploy, get } = hre.deployments;

  const network = hre.network.name;

  const chainId = await getNetworkIdFromName(network);

  if (chainId) {
    const managerContractAddress = (await get("DefiBetsManager")).address;

    const startingPoints = networkConfig[chainId].startingPoints;

    const args = [managerContractAddress, startingPoints];

    const tracker = await deploy("PointTracker", {
      from: deployer,
      log: true,
      args: args,
      autoMine: true,
      waitConfirmations: networkConfig[chainId].confirmations,
    });

    if (!developmentChains.includes(hre.network.name)) {
      await verify(tracker.address, args);
    }
  }
};

deployPointTracker.tags = ["all", "game", "tracker"];

export default deployPointTracker;
