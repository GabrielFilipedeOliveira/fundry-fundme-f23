// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*1.Deploy Mocks when we are on a local anvil chain. 

2.Keep track of contracts address across different chains.
    SEPOLIA ETH/USD
    MAINNET ETH/USD
*/

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
// If we are on a local anvil, we deploy mocks.
// Otherwise, grab the existing address from the live network. 
    
    
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig { //cria um objeto com o struct 
        address priceFeed; //ETH/USD price feed address
    }

    constructor(){
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        }else if(block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        }else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
        
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns(NetworkConfig memory){
        // price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public  returns(NetworkConfig memory){
        // price feed address
        //1.deploy the mocks (mocks its like a dumy contract we can control the contract)
        //2.return the mocks address
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}