// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ICowSettlement {
    function settle(
        address[] memory tokens,
        uint256[] memory clearingPrices,
        GPv2Trade.Data[] memory trades,
        GPv2Interaction.Data[][3] memory interactions
    ) external;
}

interface GPv2Trade {
    struct Data {
        uint256 sellTokenIndex;
        uint256 buyTokenIndex;
        address receiver;
        uint256 sellAmount;
        uint256 buyAmount;
        uint32 validTo;
        bytes32 appData;
        uint256 feeAmount;
        uint256 flags;
        uint256 executedAmount;
        bytes signature;
    }
}

interface GPv2Interaction {
    struct Data {
        address target;
        uint256 value;
        bytes callData;
    }
}
