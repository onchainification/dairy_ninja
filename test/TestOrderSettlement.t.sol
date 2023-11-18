// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

import {BaseFixture} from "./BaseFixture.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {IConditionalOrder} from "cow-order/interfaces/IConditionalOrder.sol";

import {GPv2Trade} from "../src/interfaces/ICowSettlement.sol";

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

        IERC20[] memory tokens = new IERC20[](2);
        tokens[0] = WXDAI;
        tokens[1] = WETH;

        uint256[] memory execPrices = new uint256[](2);
        execPrices[0] = wxdaiBalance;
        execPrices[1] = 1;

        // order includes our safe's plus counterparty for local test
        GPv2Trade.Data[] memory trades = new GPv2Trade.Data[](2);

        // settle order onchain
        vm.prank(FAKE_SOLVER);
        // COW_SETTLEMENT.settle(tokens, execPrices, trades, interactions);
    }
}
