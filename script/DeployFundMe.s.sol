// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script{
    function run() external returns(FundMe){
        //Before startBroadcast is not a real tx -> not spend a real gas
        HelperConfig helperConfig = new HelperConfig();
        address EthUsdPriceFeed = helperConfig.activeNetworkConfig();


        //After startBroadcast is a real tx -> spend a real gas
        vm.startBroadcast();
        FundMe fundMe = new FundMe(EthUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}