// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IApi3Oracle {
    function read() external view returns (int224 value, uint32 timestamp);
}
