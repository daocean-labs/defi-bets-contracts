import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { PointTracker } from "../typechain-types";

task("start-season", "start a new season with a new end date in x days")
  .addParam("days", "days until season ends")
  .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { ethers, deployments } = hre;

    const pointTrackerAddress = (await deployments.get("PointTracker")).address;
    const pointTracker = (await ethers.getContractAt(
      "PointTracker",
      pointTrackerAddress
    )) as PointTracker;

    const now = (await ethers.provider.getBlock("latest"))?.timestamp;

    if (now) {
      const endOfSeason = now + parseInt(taskArgs.days) * 60 * 24 * 60;

      await pointTracker.startSeason(endOfSeason);
    }

    const season = await pointTracker.getLatestSeason();

    console.log(`season ${season} is active!`);
  });
