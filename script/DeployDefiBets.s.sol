// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DefiBets} from "../src/core/DefiBets.sol";
import {DefiBetsManager} from "../src/core/DefiBetsManager.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDefiBets is Script {
    function run() external returns (DefiBets, DefiBetsManager) {
        HelperConfig config = new HelperConfig();

        (string memory underlying, uint256 timeDelta, , , , ) = config
            .activeNetworkConfig();

        vm.startBroadcast();

        DefiBetsManager defiBetsManager = new DefiBetsManager();
        DefiBets defiBets = new DefiBets(
            underlying,
            address(defiBetsManager),
            timeDelta
        );

        vm.stopBroadcast();

        return (defiBets, defiBetsManager);
    }
}
