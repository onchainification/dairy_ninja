// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

import {BaseFixture} from "./BaseFixture.sol";

contract TestOracleFeed is BaseFixture {
    function setUp() public override {
        BaseFixture.setUp();
    }

    function testOracleFeedWhitelisting() public {
        // ensure sc is WL
        bool isTolled = ORACLE_CHRONICLE.tolled(address(orderHandler));
        assertTrue(isTolled);

        // ensure price is > 0
        uint256 price = orderHandler.getOraclePrice();
        console.log(price);
        assertGt(price, 0);
    }
}
