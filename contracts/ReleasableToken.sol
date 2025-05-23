// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";

/// @title ReleasableToken
/// @notice An ERC20 token with upgradeable functionality and access control
/// @dev Extends OpenZeppelin's ERC20, UUPS, and AccessManaged contracts
contract ReleasableToken is
    Initializable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    UUPSUpgradeable,
    AccessManagedUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the token with name and symbol
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    function initialize(
        string calldata name,
        string calldata symbol
    ) public initializer {
        __ERC20_init(name, symbol);
        __ERC20Permit_init(name);
        __UUPSUpgradeable_init();
        __AccessManaged_init(msg.sender);
    }

    /// @notice Mints new tokens to the specified address
    /// @param to The address to receive the minted tokens
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) public restricted {
        _mint(to, amount);
    }

    /// @notice Checks if the caller has permission to upgrade the contract
    function hasUpgradePermission() public restricted {}

    /// @notice Internal function to authorize contract upgrades
    function _authorizeUpgrade(address) internal override {
        hasUpgradePermission();
    }
}
