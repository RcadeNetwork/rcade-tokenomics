// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/manager/AccessManaged.sol";

/// @title ReleasableToken
/// @notice An ERC20 token with upgradeable functionality and access control
/// @dev Extends OpenZeppelin's ERC20, UUPS, and AccessManaged contracts
contract ReleasableToken is ERC20, ERC20Permit, AccessManaged {
    bool public initialized;

    constructor(string memory name, string memory symbol) 
        ERC20(name, symbol) 
        ERC20Permit(name)
        AccessManaged(msg.sender) {
    }

    /// @notice Initializes the token and mints the total supply to the specified address
    /// @param tokenReceiver The address to receive the minted tokens
    function initialize(address tokenReceiver) public restricted {
        require(!initialized, "Token already initialized");
        _mint(tokenReceiver, 40000000000000000000000000000);
        initialized = true;
    }
}
