import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { BTCPriceOracle } from "../typechain-types";

task("set-price", "set a new price for the oracle")
  .addParam("price", "Price in $")
  .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { ethers } = hre;

    const { parseEther } = ethers;

    const price = parseEther(taskArgs.price);

    const priceOracleAddress = (await hre.deployments.get("BTCPriceOracle"))
      .address;
    const oracle = (await ethers.getContractAt(
      "BTCPriceOracle",
      priceOracleAddress
    )) as BTCPriceOracle;

    const trx = await oracle.updateAnswer(price);
    await trx.wait();

    console.log(`Set a new price for BTC: ${price} $`);
  });
