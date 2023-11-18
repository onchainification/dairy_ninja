// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

import {BaseFixture} from "./BaseFixture.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {GPv2Order} from "cowprotocol/libraries/GPv2Order.sol";
import {GPv2Signing} from "cowprotocol/mixins/GPv2Signing.sol";

import {GPv2TradeEncoder} from "lib/cow/test/vendored/GPv2TradeEncoder.sol";
import {TestAccount, TestAccountLib} from "lib/cow/test/libraries/TestAccountLib.t.sol";

import {IConditionalOrder} from "cow-order/interfaces/IConditionalOrder.sol";

import {GPv2Trade, GPv2Interaction} from "../src/interfaces/ICowSettlement.sol";

import {OrderHandler} from "src/OrderHandler.sol";

contract TestOrderSettlement is BaseFixture {
    using TestAccountLib for TestAccount;

    function setUp() public override {
        BaseFixture.setUp();
    }

    function testSafeOrderSettlement() public {
        // NOTE: indicates single-order
        bytes32[] memory proof = new bytes32[](0);

        // read balance of SAFE
        uint256 wxdaiBalance = WXDAI.balanceOf(GNOSIS_CHAIN_SAFE);
        console.log(wxdaiBalance);
        // ensure safe has positive balance of `WXDAI`
        assertGt(wxdaiBalance, 0);

        // single order creation
        OrderHandler.Data memory orderDets = OrderHandler.Data({
            sellToken: WXDAI,
            buyToken: WETH,
            receiver: GNOSIS_CHAIN_SAFE,
            sellAmount: wxdaiBalance,
            buyAmount: 2000 ether, // assume 2k price eth/usd (fake)
            validTo: uint32(block.timestamp + 2 days) // assumes is valid from now till 2d in the future
        });
        IConditionalOrder.ConditionalOrderParams memory params = IConditionalOrder.ConditionalOrderParams({
            handler: orderHandler,
            salt: keccak256(abi.encode(bytes32(0))),
            staticInput: abi.encode(orderDets)
        });

        // approve sell token to the relayer
        vm.prank(GNOSIS_CHAIN_SAFE);
        WXDAI.approve(COW_RELAYER, wxdaiBalance);
        assertEq(WXDAI.allowance(GNOSIS_CHAIN_SAFE, COW_RELAYER), wxdaiBalance);

        // impersonate safe to create order and verify its creation
        vm.prank(GNOSIS_CHAIN_SAFE);
        composableCow.create(params, true);
        assertEq(composableCow.singleOrders(GNOSIS_CHAIN_SAFE, keccak256(abi.encode(params))), true);

        // empty interactions for before, during and after the settlement in our case
        GPv2Interaction.Data[][3] memory interactions =
            [new GPv2Interaction.Data[](0), new GPv2Interaction.Data[](0), new GPv2Interaction.Data[](0)];

        (GPv2Order.Data memory order, bytes memory signature) =
            composableCow.getTradeableOrderWithSignature(GNOSIS_CHAIN_SAFE, params, bytes(""), proof);

        // ensure dets outputted are as expected from conditiona order dets creation
        assertEq(address(orderDets.sellToken), address(order.sellToken));
        assertEq(address(orderDets.buyToken), address(order.buyToken));
        assertEq(orderDets.receiver, order.receiver);
        assertEq(orderDets.buyAmount, order.buyAmount);

        // counter trade from counterMaxi
        GPv2Order.Data memory counterOrder = GPv2Order.Data({
            sellToken: order.buyToken,
            buyToken: order.sellToken,
            receiver: address(0),
            sellAmount: order.buyAmount,
            buyAmount: order.sellAmount,
            validTo: order.validTo,
            appData: order.appData,
            feeAmount: 0,
            kind: GPv2Order.KIND_BUY,
            partiallyFillable: false,
            buyTokenBalance: GPv2Order.BALANCE_ERC20,
            sellTokenBalance: GPv2Order.BALANCE_ERC20
        });

        vm.prank(counterMaxi.addr);
        WETH.approve(COW_RELAYER, counterOrder.sellAmount);

        address[] memory tokens = new address[](2);
        tokens[0] = address(order.sellToken);
        tokens[1] = address(order.buyToken);

        uint256[] memory execPrices = new uint256[](2);
        execPrices[0] = counterOrder.sellAmount;
        execPrices[1] = counterOrder.buyAmount;

        // order includes our safe's plus counterparty for local test
        GPv2Trade.Data[] memory trades = new GPv2Trade.Data[](2);

        // 1. safe trade
        trades[0] = GPv2Trade.Data({
            sellTokenIndex: 0,
            buyTokenIndex: 1,
            receiver: order.receiver,
            sellAmount: order.sellAmount,
            buyAmount: order.buyAmount,
            validTo: order.validTo,
            appData: order.appData,
            feeAmount: order.feeAmount,
            flags: GPv2TradeEncoder.encodeFlags(order, GPv2Signing.Scheme.Eip1271),
            executedAmount: order.sellAmount,
            signature: abi.encodePacked(order.receiver, signature)
        });

        // hash signing
        bytes32 hashToSign = GPv2Order.hash(counterOrder, COW_SETTLEMENT.domainSeparator());
        bytes memory counterPartySig = counterMaxi.signPacked(hashToSign);

        // 2. counter-party trade
        trades[1] = GPv2Trade.Data({
            sellTokenIndex: 1,
            buyTokenIndex: 0,
            receiver: address(0),
            sellAmount: counterOrder.sellAmount,
            buyAmount: counterOrder.buyAmount,
            validTo: counterOrder.validTo,
            appData: counterOrder.appData,
            feeAmount: counterOrder.feeAmount,
            flags: GPv2TradeEncoder.encodeFlags(counterOrder, GPv2Signing.Scheme.Eip712),
            executedAmount: counterOrder.sellAmount,
            signature: counterPartySig
        });

        // settle order onchain
        vm.prank(FAKE_SOLVER);
        COW_SETTLEMENT.settle(tokens, execPrices, trades, interactions);
    }
}
