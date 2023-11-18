// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ISafeProtocolPlugin} from "safe-protocol/interfaces/Modules.sol";
import {PLUGIN_PERMISSION_EXECUTE_CALL} from "safe-protocol/common/Constants.sol";

contract DairyNinjaModule is ISafeProtocolPlugin {
    /*//////////////////////////////////////////////////////////////////////////
                                   PUBLIC STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    address public manager;

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/
    constructor(address _manager) {
        // Safe Protocol config
        manager = _manager;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    PUBLIC VIEWS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice A funtion that returns name of the plugin
    function name() external view override returns (string memory name) {
        return "DAIRY_NINJA";
    }

    /// @notice A function that returns version of the plugin
    function version() external view override returns (string memory version) {
        return "v0.0.1";
    }

    function metadataProvider() external view override returns (uint256 providerType, bytes memory location) {}

    /// @notice A function that indicates permissions required
    function requiresPermissions() external view override returns (uint8 permissions) {
        return PLUGIN_PERMISSION_EXECUTE_CALL;
    }

    /// @dev Returns true if this contract implements the interface defined by interfaceId
    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return interfaceId == type(ISafeProtocolPlugin).interfaceId || interfaceId == 0x01ffc9a7;
    }
}
