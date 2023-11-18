// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";

import {IChronicleOracle} from "../src/interfaces/IChronicleOracle.sol";

// import {ComposableCoW} from "cow-order/ComposableCoW.sol";

import {OrderHandler} from "src/OrderHandler.sol";

contract BaseFixture is Test {
    OrderHandler orderHandler;

    // ComposableCoW composableCow;

    address constant RELY_AUTH_ORACLE = 0xc50dFeDb7E93eF7A3DacCAd7987D0960c4e2CD4b;

    IChronicleOracle constant ORACLE_CHRONICLE = IChronicleOracle(0x5E16CA75000fb2B9d7B1184Fa24fF5D938a345Ef);

    function setUp() public virtual {
        // block height: https://gnosisscan.io/block/31008982
        vm.createSelectFork("gnosis", 31008982);

        // ref: https://github.com/cowprotocol/composable-cow/tree/ab3addad9bc05acdbf5fb040eb5c336209b58e31#deployed-contracts
        // composableCow = ComposableCoW(0xfdaFc9d1902f4e0b84f65F49f244b32b31013b74);
        // deploy handler
        orderHandler = new OrderHandler();

        // auth order handler. IRL: go to sponsor and ask them WL 🙏
        vm.prank(RELY_AUTH_ORACLE);
        ORACLE_CHRONICLE.rely(address(orderHandler));

        orderHandler.kissMe();
    }
}
