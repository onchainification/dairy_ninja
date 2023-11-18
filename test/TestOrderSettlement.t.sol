// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

import {BaseFixture} from "./BaseFixture.sol";

import {IConditionalOrder} from "cow-order/interfaces/IConditionalOrder.sol";

import {OrderHandler} from "src/OrderHandler.sol";

contract TestOrderSettlement is BaseFixture {
    function setUp() public override {
        BaseFixture.setUp();
    }

    function testSafeOrderSettlement() public {
        uint256 wxdaiBalance = WXDAI.balanceOf(GNOSIS_CHAIN_SAFE);
        console.log(wxdaiBalance);
        // ensure safe has positive balance of `WXDAI`
        assertGt(wxdaiBalance, 0);

        // single order creation
        OrderHandler.Data memory orderDets =
            OrderHandler.Data({sellToken: WXDAI, buyToken: WETH, receiver: GNOSIS_CHAIN_SAFE, buyAmount: 1});
        IConditionalOrder.ConditionalOrderParams memory params = IConditionalOrder.ConditionalOrderParams({
            handler: orderHandler,
            salt: keccak256(abi.encode(bytes32(0))),
            staticInput: abi.encode(orderDets)
        });

        // approve sell token to the relayer
        vm.prank(GNOSIS_CHAIN_SAFE);
        WXDAI.approve(COW_RELAYER, wxdaiBalance);

        // impersonate safe to create order and verify its creation
        vm.prank(GNOSIS_CHAIN_SAFE);
        composableCow.create(params, true);
        assertEq(composableCow.singleOrders(GNOSIS_CHAIN_SAFE, keccak256(abi.encode(params))), true);

        // settle order onchain
    }
}
