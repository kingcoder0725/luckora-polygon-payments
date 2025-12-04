// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {PaymentGatewayV2} from "../src/PaymentGatewayV2.sol";

contract DeployAnvilScript is Script {
    function run() public returns (PaymentGatewayV2) {
        // Get owner address from environment variable, or use msg.sender
        address owner = vm.envOr("ANVIL_OWNER_ADDRESS", msg.sender);
        
        vm.startBroadcast();

        PaymentGatewayV2 gateway = new PaymentGatewayV2(owner);

        vm.stopBroadcast();

        // Log deployment information
        console.log("PaymentGatewayV2 deployed at:", address(gateway));
        console.log("Network: Anvil (Local)");
        console.log("Owner address:", owner);
        console.log("Deployer address:", msg.sender);
        console.log("Supports: Native ETH + ERC20/BEP20 tokens (USDT, etc.)");

        return gateway;
    }
}

