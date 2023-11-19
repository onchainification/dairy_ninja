// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IGnosisSafe {
    function enableModule(address module) external;

    function isModuleEnabled(address module) external view returns (bool);
}
