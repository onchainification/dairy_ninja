// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";

import {ComposableCoW} from "cow-order/ComposableCoW.sol";

import {OrderHandler} from "../src/OrderHandler.sol";

contract OrderHnadlerDeploy is Script {
    OrderHandler orderHandler;

    ComposableCoW composableCow;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        composableCow = ComposableCoW(0xfdaFc9d1902f4e0b84f65F49f244b32b31013b74);

        orderHandler = new OrderHandler(composableCow);
    }
}
