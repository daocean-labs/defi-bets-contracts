import { parseEther } from "ethers";

interface INetworkConfig {
  [key: number]: any;
}
export const networkConfig: INetworkConfig = {
  1133: {
    name: "dmcTestnet",
    minDuration: 43200,
    maxDuration: 604800,
    priceFeed: "0x",
    volatilityFeed: "0x",
    timeDelta: 43200,
    slot: parseEther("100"),
    decimalsIV: 4,
    initialAnswerIV: 2000,
    periodIV: 30 * 60 * 60 * 24,
    decimalsPriceFeed: 18,
    initialAnswerPrice: parseEther("29000"),
    confirmations: 2,
  },
  31337: {
    name: "localhost",
    minDuration: 43200,
    maxDuration: 604800,
    priceFeed: "0x",
    volatilityFeed: "0x",
    timeDelta: 43200,
    slot: parseEther("100"),
    decimalsIV: 4,
    initialAnswerIV: 2000,
    periodIV: 30 * 60 * 60 * 24,
    decimalsPriceFeed: 18,
    initialAnswerPrice: parseEther("29000"),
    confirmations: 2,
  },
};

export const developmentChains = ["hardhat", "localhost"];

export const getNetworkIdFromName = async (networkIdName: string) => {
  for (const id in networkConfig) {
    if (networkConfig[id]["name"] === networkIdName) {
      return Number(id);
    }
  }
  return null;
};
