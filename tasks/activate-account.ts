import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { PointTracker } from "../typechain-types";

task(
  "activate-account",
  "activate a new account and get 100 betting points"
).setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
  const { ethers } = hre;

  const pointTrackerAddress = (await hre.deployments.get("PointTracker"))
    .address;
  const pointTracker = (await ethers.getContractAt(
    "PointTracker",
    pointTrackerAddress
  )) as PointTracker;

  const player = (await ethers.getSigners())[0];

  const activeSeason = await pointTracker.getLatestSeason();
  const hasPoints = await pointTracker.getPlayerPoints(
    activeSeason,
    player.address
  );

  if (hasPoints) {
    console.log("Player is already active!");
  } else {
    const trx = await pointTracker.activateAccount();
    await trx.wait();
    console.log(`Player ${player.address} ia activated!`);
  }
});
