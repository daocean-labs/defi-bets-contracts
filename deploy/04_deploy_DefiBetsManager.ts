import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  getNetworkIdFromName,
  networkConfig,
  developmentChains,
} from "../helper-hardhat-config";
import { verify } from "../helper-functions";

const deployDefiBetsManager: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployer } = await hre.getNamedAccounts();

  const { deploy, get } = hre.deployments;

  const network = hre.network.name;

  const chainId = await getNetworkIdFromName(network);

  if (chainId) {
    const library = await get("MathLibraryDefibets");

    const manager = await deploy("DefiBetsManager", {
      from: deployer,
      args: [],
      log: true,
      autoMine: true,
      libraries: {
        MathLibraryDefibets: library.address,
      },
      waitConfirmations: networkConfig[chainId].confirmations || 1,
    });

    if (!developmentChains.includes(hre.network.name)) {
      await verify(manager.address, []);
    }
  }
};

deployDefiBetsManager.tags = ["all", "game", "manager"];

export default deployDefiBetsManager;
