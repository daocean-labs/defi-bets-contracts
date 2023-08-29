//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {Script, console2} from "forge-std/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        string underlying;
        uint256 timeDelta;
        uint256 dependentTimeStamp;
        uint256 minBetDuration;
        uint256 maxBetDuration;
        uint256 slot;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 1331) {
            activeNetworkConfig = getDMCTestnetConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getDMCTestnetConfig()
        public
        view
        returns (NetworkConfig memory dmcTestnteConfig)
    {
        dmcTestnteConfig = NetworkConfig({
            underlying: "BTC",
            timeDelta: 60 * 60 * 24,
            dependentTimeStamp: block.timestamp,
            minBetDuration: 1 * 24 * 60 * 60,
            maxBetDuration: 7 * 24 * 60 * 60,
            slot: 100e18
        });
    }

    function getAnvilConfig()
        public
        view
        returns (NetworkConfig memory anvilConfig)
    {
        anvilConfig = NetworkConfig({
            underlying: "BTC",
            timeDelta: 60 * 60 * 24,
            dependentTimeStamp: block.timestamp,
            minBetDuration: 1 * 24 * 60 * 60,
            maxBetDuration: 7 * 24 * 60 * 60,
            slot: 100e18
        });
    }
}
