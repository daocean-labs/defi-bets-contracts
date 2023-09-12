import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { ImpliedVolatilityOracle } from "../typechain-types";

task("set-vola", "Set the implied volatility of BTC")
  .addParam("vola", "Vola with 4 decimal")
  .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { ethers, deployments } = hre;

    const volaOracleAddress = (await deployments.get("ImpliedVolatilityOracle"))
      .address;
    const volaOracle = (await ethers.getContractAt(
      "ImpliedVolatilityOracle",
      volaOracleAddress
    )) as ImpliedVolatilityOracle;

    const vola = parseInt(taskArgs.vola);
    if (vola) {
      const trx = await volaOracle.updateAnswer(vola);
      await trx.wait();

      console.log("Implied Volatility Updated!!");
    }
  });
