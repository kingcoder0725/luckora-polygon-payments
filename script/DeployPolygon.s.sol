// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {PaymentGatewayV2} from "../src/PaymentGatewayV2.sol";

contract DeployPolygonScript is Script {
    function run() public returns (PaymentGatewayV2) {
        // Use provided owner if set, otherwise default to deployer
        address owner = vm.envOr("POLYGON_OWNER_ADDRESS", msg.sender);

        vm.startBroadcast();
        PaymentGatewayV2 gateway = new PaymentGatewayV2(owner);
        vm.stopBroadcast();

        console.log("PaymentGatewayV2 deployed at:", address(gateway));
        console.log("Network: Polygon Mainnet");
        console.log("Owner address:", owner);
        console.log("Deployer address:", msg.sender);
        console.log("Supports: Native MATIC + ERC20 tokens (USDT, USDC, WBTC, WETH, AAVE, CRV, LINK)");

        return gateway;
    }
}

