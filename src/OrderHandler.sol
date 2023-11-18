// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ComposableCoW} from "cow-order/ComposableCoW.sol";
import {BaseConditionalOrder} from "cow-order/BaseConditionalOrder.sol";

import {GPv2Order} from "cowprotocol/libraries/GPv2Order.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {ISelfKiss} from "./interfaces/ISelfKiss.sol";
import {IChronicleOracle} from "./interfaces/IChronicleOracle.sol";

/// @title OrderHandler
/// @notice Handler allows to ensure that the order details are executed according to onchain conditions.
/// @dev Designed to be used with the CoW Protocol Conditional Order Framework.
contract OrderHandler is BaseConditionalOrder {
    /*//////////////////////////////////////////////////////////////////////////
                                ORDER STRUCT
    //////////////////////////////////////////////////////////////////////////*/
    struct Data {
        IERC20 sellToken;
        IERC20 buyToken;
        address receiver;
        uint256 buyAmount;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/

    // https://gnosisscan.io/address/0x0Dcc19657007713483A5cA76e6A7bbe5f56EA37d#code
    ISelfKiss constant SELF_KISS_CHRONICLE = ISelfKiss(0x0Dcc19657007713483A5cA76e6A7bbe5f56EA37d);

    // https://docs.chroniclelabs.org/docs/hackathons/eth-global-istanbul-hackathon#smart-contract-addresses-on-gnosis-mainnet
    IChronicleOracle constant ORACLE_CHRONICLE = IChronicleOracle(0xc8A1F9461115EF3C1E84Da6515A88Ea49CA97660);

    ComposableCoW public immutable composableCow;

    constructor(ComposableCoW _composableCow) {
        // self WL the SC itself on deployment
        SELF_KISS_CHRONICLE.selfKiss(address(ORACLE_CHRONICLE), address(this));
        // set the composable sc addy
        composableCow = _composableCow;
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
        // decode `staticInput` received in the handler following struct pattern
        Data memory dets = abi.decode(staticInput, (Data));

        // TODO: check quote VS oracles!!!!

        // construct order
        order = GPv2Order.Data({
            sellToken: dets.sellToken,
            buyToken: dets.buyToken,
            receiver: dets.receiver,
            sellAmount: uint256(0),
            buyAmount: dets.buyAmount,
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
