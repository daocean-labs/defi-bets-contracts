import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { BTCPriceOracle, ImpliedVolatilityOracle } from "../typechain-types";

task(
  "transfer-oracle-ownership",
  "Transfer the ownership of all oracle contracts"
)
  .addParam("owner", "The new owner address of the contracts")
  .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { ethers } = hre;

    const newOwner = taskArgs.owner;

    const priceOracleAddress = (await hre.deployments.get("BTCPriceOracle"))
      .address;
    const oracle = (await ethers.getContractAt(
      "BTCPriceOracle",
      priceOracleAddress
    )) as BTCPriceOracle;

    console.log("transfer ownership of btc price oracle...");
    const trx = await oracle.transferOwnership(newOwner);
    await trx.wait(1);

    console.log(`New owner is ${newOwner}`);

    const volaOracleAddress = (
      await hre.deployments.get("ImpliedVolatilityOracle")
    ).address;

    const volaOracle = (await ethers.getContractAt(
      "ImpliedVolatilityOracle",
      volaOracleAddress
    )) as ImpliedVolatilityOracle;

    console.log("transfer ownership of btc vola oracle...");
    const trxVolaOwnership = await volaOracle.transferOwnership(newOwner);
    await trxVolaOwnership.wait(1);

    console.log(`New owner is ${newOwner}`);
  });
