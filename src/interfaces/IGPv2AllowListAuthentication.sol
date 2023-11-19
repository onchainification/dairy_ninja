// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IGPv2AllowListAuthentication {
    event ManagerChanged(address newManager, address oldManager);
    event SolverAdded(address solver);
    event SolverRemoved(address solver);

    function addSolver(address solver) external;
    function manager() external view returns (address);
    function isSolver(address prospectiveSolver) external view returns (bool);
}
