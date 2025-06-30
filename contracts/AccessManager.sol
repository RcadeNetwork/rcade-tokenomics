// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC721Metadata.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/manager/AccessManagerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Tokenomics.sol";
import "./ReleasableToken.sol";

/// @title AccessManager
/// @notice Manages access control and permissions for the tokenomics system
/// @dev Implements role-based access control for token and tokenomics operations
contract AccessManager is
    Initializable,
    Ownable2StepUpgradeable,
    UUPSUpgradeable,
    AccessManagerUpgradeable,
    AccessManagedUpgradeable
{
    /// @notice The tokenomics contract being managed
    Tokenomics public tokenomics;
    /// @notice The token contract being managed
    ReleasableToken public token;

    /// @notice Role ID for tokenomics maintainers
    uint64 public constant TOKENOMICS_MAINTAINER = 1;
    /// @notice Role ID for tokenomics runners
    uint64 public constant TOKENOMICS_RUNNER = 2;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the access manager
    /// @param tokenomics_ The address of the tokenomics contract
    /// @param token_ The address of the token contract
    function initialize(
        address tokenomics_,
        address token_
    ) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        __AccessManager_init(msg.sender);
        __AccessManaged_init(msg.sender);

        tokenomics = Tokenomics(tokenomics_);
        token = ReleasableToken(token_);

        grantRole(ADMIN_ROLE, address(this), 0);
    }

    /// @notice Sets roles for specific function selectors on a target contract
    /// @param target The address of the target contract
    /// @param selectors The function selectors to set roles for
    /// @param roleId The role ID to assign
    function setRoles(address target, bytes4[] calldata selectors, uint64 roleId) external restricted {
        setTargetFunctionRole(target, selectors, roleId);
    }

    /// @notice Applies predefined roles to tokenomics and token functions
    function applyRoles() external restricted {
        // Tokenomics roles
        _setTargetFunctionRole(address(tokenomics), tokenomics.transferUnlockedTokens.selector, TOKENOMICS_RUNNER);
        _setTargetFunctionRole(address(tokenomics), tokenomics.transferUnlockedTokensForReleaseGroup.selector, TOKENOMICS_RUNNER);
        _setTargetFunctionRole(address(tokenomics), tokenomics.batchAddTokenReleaseGroups.selector, TOKENOMICS_MAINTAINER);
        _setTargetFunctionRole(address(tokenomics), tokenomics.pause.selector, TOKENOMICS_MAINTAINER);
        _setTargetFunctionRole(address(tokenomics), tokenomics.unpause.selector, TOKENOMICS_MAINTAINER);
        _setTargetFunctionRole(address(tokenomics), tokenomics.setTGETime.selector, TOKENOMICS_MAINTAINER);
        _setTargetFunctionRole(address(tokenomics), tokenomics.setTokenReleaseGroupReceiverAddress.selector, TOKENOMICS_MAINTAINER);
        _setTargetFunctionRole(address(tokenomics), tokenomics.hasUpgradePermission.selector, TOKENOMICS_MAINTAINER);
        
        _setTargetFunctionRole(address(token), token.initialize.selector, ADMIN_ROLE);
        
        grantRole(TOKENOMICS_MAINTAINER, msg.sender, 0);
        grantRole(TOKENOMICS_RUNNER, msg.sender, 0);
    }

    /// @notice Returns the current version of the contract
    /// @return The version number
    function version() external pure returns (uint256) {
        return 1;
    }

    /// @notice Checks if the caller has permission to upgrade the contract
    function hasUpgradePermission() public restricted {}

    /// @notice Internal function to authorize contract upgrades
    function _authorizeUpgrade(address) internal override {
        hasUpgradePermission();
    }
}
