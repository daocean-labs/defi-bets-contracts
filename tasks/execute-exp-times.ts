import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DefiBets, DefiBetsManager } from "../typechain-types";
import { formatEther } from "ethers";

task("execute-exp-times", "Execute all possible expiration times").setAction(
  async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { ethers, deployments } = hre;

    const defiBetsAddress = (await deployments.get("DefiBets")).address;
    const defiBets = (await ethers.getContractAt(
      "DefiBets",
      defiBetsAddress
    )) as DefiBets;
    const managerAddress = (await deployments.get("DefiBetsManager")).address;
    const manager = (await ethers.getContractAt(
      "DefiBetsManager",
      managerAddress
    )) as DefiBetsManager;

    const hash = await manager.getUnderlyingByte("BTC");
    const priceFeedAddress = await manager.underlyingPriceFeeds(hash);
    const priceFeed = await ethers.getContractAt(
      "BTCPriceOracle",
      priceFeedAddress
    );

    const filter = defiBets.filters.EpxirationTimeCreated;
    const expTimesEvents = await defiBets.queryFilter(filter);

    const time = Date.now();
    const expTimes: bigint[] = [];
    for (let i = 0; i < expTimesEvents.length; i++) {
      const _expTime = expTimesEvents[i].args.expTime;
      const info = await defiBets.expTimeInfos(_expTime);
      if (!info.finished && time / 1000 > _expTime) {
        expTimes.push(_expTime);
      }
    }
    if (expTimes.length > 0) {
      console.log(
        `Start execution of expiration times (Total: ${expTimes.length})`
      );
      for (let i = 0; i < expTimes.length; i++) {
        const answer = await priceFeed.latestRoundData();
        let updatedAt = answer.updatedAt;
        let roundId = answer.roundId;

        let price;

        while (updatedAt > expTimes[i]) {
          roundId--;
          const roundData = await priceFeed.getRoundData(roundId);

          updatedAt = roundData.updatedAt;
          price = roundData.answer;
        }
        if (price) {
          console.log(
            `Find last price before exp time: ${formatEther(
              price
            )} at ${new Date(
              Number(updatedAt) * 1000
            ).toLocaleDateString()},${new Date(
              Number(updatedAt) * 1000
            ).toLocaleTimeString()}`
          );
        }
        const executeFunction = manager.getFunction("executeExpiration");

        const gas = await executeFunction.estimateGas(
          expTimes[i],
          "BTC",
          roundId
        );

        const trx = await executeFunction.send(expTimes[i], "BTC", roundId, {
          gasLimit: (gas * BigInt(120)) / BigInt(100),
        });
        await trx.wait(1);
        console.log(`ExpTime ${expTimes[i]} is executed!`);
      }
      console.log("finished!!");
    } else {
      console.log("No Exp times for execution!");
    }
  }
);
