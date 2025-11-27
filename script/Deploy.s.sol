// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {PaymentGateway} from "../src/PaymentGateway.sol";

contract DeployScript is Script {
    function run() public returns (PaymentGateway) {
        vm.startBroadcast();

        address owner = msg.sender;
        PaymentGateway gateway = new PaymentGateway(owner);

        vm.stopBroadcast();

        return gateway;
    }
}

