// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {IChronicleOracle} from "../src/interfaces/IChronicleOracle.sol";
import {IGPv2AllowListAuthentication} from "../src/interfaces/IGPv2AllowListAuthentication.sol";

import {ComposableCoW} from "cow-order/ComposableCoW.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {OrderHandler} from "src/OrderHandler.sol";

contract BaseFixture is Test {
    OrderHandler orderHandler;

    ComposableCoW composableCow;

    // fake solver agent
    address constant FAKE_SOLVER = 0x5b47121521fBcAE0dFFfbC312Bb73fE88F4E8BE6;

    // gnosis safe address
    address constant GNOSIS_CHAIN_SAFE = 0xa4A4a4879dCD3289312884e9eC74Ed37f9a92a55;

    // tokens
    IERC20 constant WXDAI = IERC20(0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d);
    IERC20 constant WETH = IERC20(0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1);

    // cowswap infra: https://docs.cow.fi/smart-contracts/introduction
    address constant COW_RELAYER = 0xC92E8bdf79f0507f65a392b0ab4667716BFE0110;

    IGPv2AllowListAuthentication constant COW_ALLOW_LIST =
        IGPv2AllowListAuthentication(0x2c4c28DDBdAc9C5E7055b4C863b72eA0149D8aFE);

    // NOTE: found addy in https://gnosisscan.io/address/0x5e16ca75000fb2b9d7b1184fa24ff5d938a345ef#readContract#F2
    address constant RELY_AUTH_ORACLE = 0xc50dFeDb7E93eF7A3DacCAd7987D0960c4e2CD4b;

    // https://docs.chroniclelabs.org/docs/hackathons/eth-global-istanbul-hackathon#smart-contract-addresses-on-gnosis-mainnet
    IChronicleOracle constant ORACLE_CHRONICLE = IChronicleOracle(0xc8A1F9461115EF3C1E84Da6515A88Ea49CA97660);

    function setUp() public virtual {
        // block height: https://gnosisscan.io/block/31008982
        vm.createSelectFork("gnosis", 31008982);

        // ref: https://github.com/cowprotocol/composable-cow/tree/ab3addad9bc05acdbf5fb040eb5c336209b58e31#deployed-contracts
        composableCow = ComposableCoW(0xfdaFc9d1902f4e0b84f65F49f244b32b31013b74);
        // deploy handler
        orderHandler = new OrderHandler(composableCow);

        // authorize the solver to fake orders
        vm.prank(COW_ALLOW_LIST.manager());
        COW_ALLOW_LIST.addSolver(FAKE_SOLVER);
        assertTrue(COW_ALLOW_LIST.isSolver(FAKE_SOLVER));
    }
}
