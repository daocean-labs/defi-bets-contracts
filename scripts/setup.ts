import { deployments, ethers, network } from "hardhat";
import { getNetworkIdFromName, networkConfig } from "../helper-hardhat-config";
import { BaseContract, formatUnits, parseUnits } from "ethers";

async function main() {
  const networkName = network.name;
  const chainID = await getNetworkIdFromName(networkName);

  if (chainID) {
    const underlyingName = "BTC";

    const minDuration = networkConfig[chainID].minDuration;
    const maxDuration = networkConfig[chainID].maxDuration;
    const slot = networkConfig[chainID].slot;

    //Period of Vola oracle
    const periodVola = networkConfig[chainID].periodIV;

    const managerAddress = (await deployments.get("DefiBetsManager")).address;
    const managerContract = await ethers.getContractAt(
      "DefiBetsManager",
      managerAddress
    );

    //smart contract addresses
    const priceFeed = (await deployments.get("BTCPriceOracle")).address;
    const defiBets = (await deployments.get("DefiBets")).address;
    const volaFeed = (await deployments.get("ImpliedVolatilityOracle")).address;
    const pointTracker = (await deployments.get("PointTracker")).address;

    const hash = await managerContract.getUnderlyingByte("BTC");

    console.log("Adding the underlying to the manager contract...");
    console.log(`Underlying: ${underlyingName}`);
    console.log(`Price Feed: ${priceFeed}`);
    console.log(`IV Feed: ${volaFeed}`);
    console.log(`DefiBets: ${defiBets}`);

    try {
      const trxAddUnderlying = await managerContract.addUnderlyingToken(
        underlyingName,
        priceFeed,
        defiBets
      );
      await trxAddUnderlying.wait(1);
    } catch (e) {
      console.error(e);
    }

    try {
      const trxUpdateIVFeed = await managerContract.updateIVFeed(
        hash,
        volaFeed,
        periodVola
      );
      await trxUpdateIVFeed.wait(1);
    } catch (e) {
      console.error(e);
    }

    try {
      const func = managerContract.getFunction("setPointTracker");

      const gas = await func.estimateGas(pointTracker);

      const trxSetPointTracker = await func.send(pointTracker, {
        gasLimit: (gas * BigInt(120)) / BigInt(100),
      });
      await trxSetPointTracker.wait();
    } catch (e) {
      console.error(e);
    }

    console.log("Initialize the DefiBets Contract...");

    const now = Date.now();
    const nextDate = new Date(now);

    nextDate.setDate(nextDate.getDate());

    nextDate.setHours(20);
    nextDate.setMinutes(0);
    nextDate.setSeconds(0);
    nextDate.setMilliseconds(0);

    console.log(`Expiration time: ${nextDate.toLocaleTimeString()}`);
    console.log(`Expiration Date: ${nextDate.toDateString()}`);
    console.log(`Min Duration: ${minDuration}`);
    console.log(`Max Duration: ${maxDuration}`);
    console.log(`Slot size: ${slot}`);

    const trxInitBets = await managerContract.initializeBets(
      hash,
      nextDate.getTime() / 1000,
      minDuration,
      maxDuration,
      slot
    );
    await trxInitBets.wait(1);

    console.log("Finished!");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
