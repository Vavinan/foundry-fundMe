// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdpriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast(); // no gas used for above part since it is outside of broadcast
        //FundMe fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        FundMe fundme = new FundMe(ethUsdpriceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}
