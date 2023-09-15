import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DefiBets, DefiBetsManager } from "../typechain-types";

task("init-exp-times", "Initialize all possible exp times ").setAction(
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

    //getting all informations

    const maxDuration = (await defiBets.maxBetDuration()) as bigint;
    if (Number(maxDuration) != 0) {
      const block = await ethers.provider.getBlock("latest");
      const now = block?.timestamp;
      const depndentTimeStamp =
        (await defiBets.getDependentExpTime()) as bigint;
      const delta = (await defiBets.timeDelta()) as bigint;

      const maxExpTime = now ? Number(maxDuration) + now : 0;
      const maxPossibleSteps = Math.ceil(
        (maxExpTime - Number(depndentTimeStamp)) / Number(delta)
      );

      const underlyingByte = await manager.getUnderlyingByte("BTC");

      for (let i = 0; i < maxPossibleSteps; i++) {
        const expTime = depndentTimeStamp + delta * BigInt(i);
        const info = await defiBets.expTimeInfos(expTime);
        const date = new Date(Number(expTime) * 1000);
        if (info.init != true) {
          console.log(`Create new exp time...`);
          try {
            const func = manager.getFunction("createNewExpTime");
            const estimateGas = await func.estimateGas(underlyingByte);
            const trx = await func.send(underlyingByte, {
              gasLimit: (estimateGas * BigInt(120)) / BigInt(100),
            });
            await trx.wait();
          } catch (e) {
            console.error(e);
          }
        } else {
          console.log("Exp time already activated!");
        }
        console.log(`Expiration time: ${date.toLocaleDateString()}  `);
        console.log(`${date.toLocaleTimeString()}`);
        console.log("================================================");
      }
    } else {
      console.log("The Defi Bets contract is not initialized!");
    }
  }
);
