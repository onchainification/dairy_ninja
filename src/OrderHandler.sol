// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {console} from "forge-std/Test.sol";

import {ComposableCoW} from "cow-order/ComposableCoW.sol";
import {BaseConditionalOrder} from "cow-order/BaseConditionalOrder.sol";

import {GPv2Order} from "cowprotocol/libraries/GPv2Order.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/utils/math/Math.sol";

import {IApi3Oracle} from "./interfaces/IApi3Oracle.sol";
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
        uint256 sellAmount;
        uint256 buyAmount;
        uint32 validTo;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                   CONSTANTS
    //////////////////////////////////////////////////////////////////////////*/
    uint256 constant MAX_BPS = 10_000;
    uint256 constant MAX_ORACLE_DELAY = 2 hours;

    // https://gnosisscan.io/address/0x0Dcc19657007713483A5cA76e6A7bbe5f56EA37d#code
    ISelfKiss constant SELF_KISS_CHRONICLE = ISelfKiss(0x0Dcc19657007713483A5cA76e6A7bbe5f56EA37d);

    // https://docs.chroniclelabs.org/docs/hackathons/eth-global-istanbul-hackathon#smart-contract-addresses-on-gnosis-mainnet
    IChronicleOracle constant ORACLE_CHRONICLE = IChronicleOracle(0xc8A1F9461115EF3C1E84Da6515A88Ea49CA97660);

    // ref: https://market.api3.org/dapis/gnosis/ETH-USD
    IApi3Oracle constant ORACLE_API_THREE = IApi3Oracle(0x26690F9f17FdC26D419371315bc17950a0FC90eD);

    ComposableCoW public immutable composableCow;

    constructor(ComposableCoW _composableCow) {
        // self WL the SC itself on deployment
        SELF_KISS_CHRONICLE.selfKiss(address(ORACLE_CHRONICLE), address(this));
        // set the composable sc addy
        composableCow = _composableCow;
    }

    function getOraclePrice() public view returns (uint256) {
        return _getOraclePrice();
    }

    function _getOraclePrice() internal view returns (uint256) {
        uint32 currentTs = uint32(block.timestamp);

        (int224 valueApiThree, uint32 timestampApiThree) = ORACLE_API_THREE.read();

        // check timestamp not older than 2h [revert]
        if (currentTs - timestampApiThree > MAX_ORACLE_DELAY) revert("Too old!!!");

        // check positive value [revert]
        if (valueApiThree < 0) revert("Negative value!!");

        // check positive value chronicle [revert]
        uint256 valueChronicle = ORACLE_CHRONICLE.read();
        if (valueChronicle < 0) revert("Negative value!!");

        // NOTE: [NAIVE APPROACH!] choose higher value between the two oracle feeds for extra health checks
        return Math.max(valueChronicle, uint256(int256(valueApiThree)));
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

        /// @dev Check actually we are selling token non-zero value
        if (dets.sellAmount == 0) revert("What are you trying???");

        /// @dev Check that quote does not deviate more than 10%. DO NOT RUG ME!
        uint256 oracleFeedsResult = (_getOraclePrice() * 9_000) / MAX_BPS;
        if (dets.buyAmount < oracleFeedsResult) revert("CowSwap endpoint is trying to rug us!!");

        // construct order
        order = GPv2Order.Data({
            sellToken: dets.sellToken,
            buyToken: dets.buyToken,
            receiver: dets.receiver,
            sellAmount: dets.sellAmount,
            buyAmount: dets.buyAmount,
            validTo: dets.validTo,
            appData: keccak256("test.kiss.me"),
            feeAmount: 0,
            kind: GPv2Order.KIND_SELL,
            partiallyFillable: false,
            sellTokenBalance: GPv2Order.BALANCE_ERC20,
            buyTokenBalance: GPv2Order.BALANCE_ERC20
        });

        /// @dev Revert if the order is expired!
        if (!(block.timestamp <= order.validTo)) revert("Order expired");
    }
}
