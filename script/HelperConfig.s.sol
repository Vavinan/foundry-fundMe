// SPDX-License-idenifier: MIT
pragma solidity ^0.8.18;

//Deploy mocks when we are on local anvin chain
// Keep track of contract address acros diff chain
import {Script} from "forge-std/Script.sol";
import {MockETHUSDAggregator} from "@chainlink/contracts/src/v0.8/automation/testhelpers/MockETHUSDAggregator.sol";


contract HelperConfig is Script {

    int256 public constant INITIAL_PRICE = 2000e8;
    uint256 public constant SEPOLIA_CHAINID = 11155111;
    uint256 public constant MAINNET_CHAINID = 1;

    NetworkConfig public activeNetworkConfig;
    struct NetworkConfig {
        address priceFeed; //ETH-USD price feed address
    }
    constructor(){
        if(block.chainid == SEPOLIA_CHAINID){
            activeNetworkConfig = getSepoliaETHConfig();
        } else if(block.chainid == MAINNET_CHAINID){
            activeNetworkConfig = getMainNetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        // price feed address
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockETHUSDAggregator mockPriceFeed = new MockETHUSDAggregator(INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
    function getMainNetEthConfig() public pure returns (NetworkConfig memory){
            return NetworkConfig({
            priceFeed:0x5424384B256154046E9667dDFaaa5e550145215e
        });
    }
}
