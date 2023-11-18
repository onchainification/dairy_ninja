// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ISelfKiss {
    error Dead();
    error NotAuthorized(address caller);
    error OracleNotSupported(address oracle);

    event AuthGranted(address indexed caller, address indexed who);
    event AuthRenounced(address indexed caller, address indexed who);
    event Killed(address indexed caller);
    event OracleSupported(address indexed caller, address indexed oracle);
    event OracleUnsupported(address indexed caller, address indexed oracle);
    event SelfKissed(address indexed caller, address indexed oracle, address indexed who);

    function authed(address who) external view returns (bool);

    function authed() external view returns (address[] memory);

    function dead() external view returns (bool);

    function deny(address who) external;

    function kill() external;

    function oracles() external view returns (address[] memory);

    function oracles(address oracle) external view returns (bool);

    function rely(address who) external;

    function selfKiss(address oracle, address who) external;

    function selfKiss(address oracle) external;

    function support(address oracle) external;

    function unsupport(address oracle) external;

    function wards(address who) external view returns (uint256);
}
