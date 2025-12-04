// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {PaymentGateway} from "../src/PaymentGateway.sol";

contract DeployBSCScript is Script {
    function run() public returns (PaymentGateway) {
        // Get owner address from environment variable, or use msg.sender
        address owner = vm.envOr("BSC_OWNER_ADDRESS", msg.sender);
        
        vm.startBroadcast();

        PaymentGateway gateway = new PaymentGateway(owner);

        vm.stopBroadcast();

        // Log deployment information
        console.log("PaymentGateway deployed at:", address(gateway));
        console.log("Network: BSC (BEP20)");
        console.log("Owner address:", owner);
        console.log("Deployer address:", msg.sender);

        return gateway;
    }
}

