// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ComposableCoW} from "cow-order/ComposableCoW.sol";
import {BaseConditionalOrder} from "cow-order/BaseConditionalOrder.sol";

import {GPv2Order} from "cowprotocol/libraries/GPv2Order.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {IChronicleOracle} from "./interfaces/IChronicleOracle.sol";

/// @title OrderHandler
/// @notice Handler allows to ensure that the order details are executed according to onchain conditions.
/// @dev Designed to be used with the CoW Protocol Conditional Order Framework.
contract OrderHandler is BaseConditionalOrder {
    /*//////////////////////////////////////////////////////////////////////////
                                   CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    // ref: https://chroniclelabs.org/dashboard/oracle/ETH/USD?blockchain=GNO&txn=0x553acf4265afea825633c10a3252e7ab532c655745a11c47d4cdff8d3714b725&contract=0x5e16ca75000fb2b9d7b1184fa24ff5d938a345ef
    IChronicleOracle constant ORACLE_CHRONICLE = IChronicleOracle(0x5E16CA75000fb2B9d7B1184Fa24fF5D938a345Ef);

    ComposableCoW public immutable composableCow;

    constructor(ComposableCoW _composableCow) {
        composableCow = _composableCow;
    }

    function kissMe() external {
        // self-kiss on deployment
        // ref: https://docs.chroniclelabs.org/docs/hackathons/eth-global-istanbul-hackathon#chronicle-protocol-contracts
        ORACLE_CHRONICLE.kiss(address(this));
    }

    function getOraclePrice() public view returns (uint256) {
        return ORACLE_CHRONICLE.read();
    }

    function getTradeableOrder(
        address owner,
        address sender,
        bytes32 ctx,
        bytes calldata staticInput,
        bytes calldata offchainInput
    ) public view override returns (GPv2Order.Data memory order) {
        // NOTE: all is DUMMY data for now!!!!
        order = GPv2Order.Data({
            sellToken: IERC20(address(0)),
            buyToken: IERC20(address(0)),
            receiver: address(0),
            sellAmount: uint256(0),
            buyAmount: uint256(0),
            validTo: uint32(block.timestamp),
            appData: keccak256("test.kiss.me"),
            feeAmount: 0,
            kind: GPv2Order.KIND_SELL,
            partiallyFillable: false,
            sellTokenBalance: GPv2Order.BALANCE_ERC20,
            buyTokenBalance: GPv2Order.BALANCE_ERC20
        });
    }
}
