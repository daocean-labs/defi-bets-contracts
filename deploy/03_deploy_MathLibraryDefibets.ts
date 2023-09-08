import { DeployFunction } from "hardhat-deploy/dist/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import {
  getNetworkIdFromName,
  networkConfig,
  developmentChains,
} from "../helper-hardhat-config";
import { verify } from "../helper-functions";

const deployMathLibraryDefibets: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployer } = await hre.getNamedAccounts();

  const { deploy } = hre.deployments;

  const network = hre.network.name;

  const chainId = await getNetworkIdFromName(network);

  if (chainId) {
    const library = await deploy("MathLibraryDefibets", {
      from: deployer,
      log: true,
      args: [],
      autoMine: true,
      waitConfirmations: networkConfig[chainId].confirmations || 1,
    });

    if (!developmentChains.includes(hre.network.name)) {
      await verify(library.address, []);
    }
  }
};

deployMathLibraryDefibets.tags = ["all", "library", "game"];

export default deployMathLibraryDefibets;
