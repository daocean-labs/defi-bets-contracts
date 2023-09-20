import { parseEther } from "ethers";
import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DefiBets, DefiBetsManager } from "../typechain-types";

task("set-bet")
  .addParam("betsize", "betsize in points")
  .addParam("min", "minPrice in dollar")
  .addParam("max", "maxPrice in dollar")
  .addParam("time", "exp time in timestamp")
  .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { ethers, deployments } = hre;

    const betSize = parseInt(taskArgs.betsize);
    const min = parseEther(taskArgs.min);
    const max = parseEther(taskArgs.max);
    const expTime = parseInt(taskArgs.time);

    const managerAddress = (await deployments.get("DefiBetsManager")).address;
    const manager = (await ethers.getContractAt(
      "DefiBetsManager",
      managerAddress
    )) as DefiBetsManager;

    const trx = await manager.setBet(betSize, min, max, expTime, "BTC");
    await trx.wait(1);
  });
