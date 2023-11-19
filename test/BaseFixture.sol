// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {IChronicleOracle} from "../src/interfaces/IChronicleOracle.sol";
import {IGPv2AllowListAuthentication} from "../src/interfaces/IGPv2AllowListAuthentication.sol";
import {ICowSettlement} from "../src/interfaces/ICowSettlement.sol";

import {ComposableCoW} from "cow-order/ComposableCoW.sol";
import {TestAccount, TestAccountLib} from "lib/cow/test/libraries/TestAccountLib.t.sol";

import {SafeProtocolRegistry} from "safe-protocol/SafeProtocolRegistry.sol";
import {SafeProtocolManager} from "safe-protocol/SafeProtocolManager.sol";
import {PLUGIN_PERMISSION_EXECUTE_CALL, MODULE_TYPE_PLUGIN} from "safe-protocol/common/Constants.sol";

import {IGnosisSafe} from "../src/interfaces/IGnosisSafe.sol";

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

import {OrderHandler} from "src/OrderHandler.sol";
import {DairyNinjaModule} from "src/DairyNinjaModule.sol";

contract BaseFixture is Test {
    using TestAccountLib for TestAccount;

    OrderHandler orderHandler;

    ComposableCoW composableCow;

    SafeProtocolRegistry registry;
    SafeProtocolManager manager;
    DairyNinjaModule module;

    // fake counter party
    TestAccount counterMaxi;

    // fake solver agent
    address constant FAKE_SOLVER = 0x5b47121521fBcAE0dFFfbC312Bb73fE88F4E8BE6;

    // gnosis safe address
    address constant GNOSIS_CHAIN_SAFE = 0xa4A4a4879dCD3289312884e9eC74Ed37f9a92a55;

    IGnosisSafe constant SAFE = IGnosisSafe(GNOSIS_CHAIN_SAFE);

    // tokens
    IERC20 constant WXDAI = IERC20(0xe91D153E0b41518A2Ce8Dd3D7944Fa863463a97d);
    IERC20 constant WETH = IERC20(0x6A023CCd1ff6F2045C3309768eAd9E68F978f6e1);

    // cowswap infra: https://docs.cow.fi/smart-contracts/introduction
    address constant COW_RELAYER = 0xC92E8bdf79f0507f65a392b0ab4667716BFE0110;

    IGPv2AllowListAuthentication constant COW_ALLOW_LIST =
        IGPv2AllowListAuthentication(0x2c4c28DDBdAc9C5E7055b4C863b72eA0149D8aFE);

    ICowSettlement constant COW_SETTLEMENT = ICowSettlement(0x9008D19f58AAbD9eD0D60971565AA8510560ab41);

    // NOTE: found addy in https://gnosisscan.io/address/0x5e16ca75000fb2b9d7b1184fa24ff5d938a345ef#readContract#F2
    address constant RELY_AUTH_ORACLE = 0xc50dFeDb7E93eF7A3DacCAd7987D0960c4e2CD4b;

    // https://docs.chroniclelabs.org/docs/hackathons/eth-global-istanbul-hackathon#smart-contract-addresses-on-gnosis-mainnet
    IChronicleOracle constant ORACLE_CHRONICLE = IChronicleOracle(0xc8A1F9461115EF3C1E84Da6515A88Ea49CA97660);

    function setUp() public virtual {
        // block height: https://gnosisscan.io/block/31014855
        vm.createSelectFork("gnosis", 31014855);

        counterMaxi = TestAccountLib.createTestAccount("counterMaxi");
        deal(address(WETH), counterMaxi.addr, 4000 ether);

        // ref: https://github.com/cowprotocol/composable-cow/tree/ab3addad9bc05acdbf5fb040eb5c336209b58e31#deployed-contracts
        composableCow = ComposableCoW(0xfdaFc9d1902f4e0b84f65F49f244b32b31013b74);
        // deploy handler
        orderHandler = new OrderHandler(composableCow);

        // authorize the solver to fake orders
        vm.prank(COW_ALLOW_LIST.manager());
        COW_ALLOW_LIST.addSolver(FAKE_SOLVER);
        assertTrue(COW_ALLOW_LIST.isSolver(FAKE_SOLVER));

        // safe protocol settings
        registry = new SafeProtocolRegistry(GNOSIS_CHAIN_SAFE);
        manager = new SafeProtocolManager(GNOSIS_CHAIN_SAFE, address(registry));
        module = new DairyNinjaModule(address(manager));

        vm.prank(GNOSIS_CHAIN_SAFE);
        SAFE.enableModule(address(manager));

        assertEq(SAFE.isModuleEnabled(address(manager)), true);

        vm.prank(GNOSIS_CHAIN_SAFE);
        registry.addModule(address(module), MODULE_TYPE_PLUGIN);

        // vm.prank(GNOSIS_CHAIN_SAFE);
        // manager.enablePlugin(address(module), PLUGIN_PERMISSION_EXECUTE_CALL);

        // add labels to help debugging in trace
        vm.label(address(FAKE_SOLVER), "FAKE_SOLVER");
        vm.label(address(GNOSIS_CHAIN_SAFE), "GNOSIS_CHAIN_SAFE");
        vm.label(address(COW_SETTLEMENT), "COW_SETTLEMENT");
        vm.label(address(ORACLE_CHRONICLE), "ORACLE_CHRONICLE");
        vm.label(address(COW_ALLOW_LIST), "COW_ALLOW_LIST");
        vm.label(address(COW_RELAYER), "COW_RELAYER");
        vm.label(address(WXDAI), "WXDAI");
        vm.label(address(WETH), "WETH");
        vm.label(address(registry), "SAFE_REGISTRY");
        vm.label(address(manager), "SAFE_MANAGER");
        vm.label(address(module), "DAIRY_NINJA_MODULE");
    }
}
