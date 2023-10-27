import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { PointTracker } from "../typechain-types";

task("finish-season", "finish the actual season").setAction(
  async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { ethers, deployments } = hre;

    const pointTrackerAddress = (await deployments.get("PointTracker")).address;
    const pointTracker = (await ethers.getContractAt(
      "PointTracker",
      pointTrackerAddress
    )) as PointTracker;

    const func = pointTracker.getFunction("finishSeason");

    const gas = await func.estimateGas();

    const trxFinishSeason = await func.send({
      gasLimit: (gas * BigInt(120)) / BigInt(100),
    });

    await trxFinishSeason.wait(1);

    // const trx = await pointTracker.finishSeason();

    // await trx.wait(1);

    console.log("Season finished!");
  }
);
