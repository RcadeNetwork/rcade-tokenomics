// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";

/// @title Tokenomics
/// @notice Manages token release schedules and vesting for different groups
/// @dev Implements a flexible token release system with cliff and vesting periods
contract Tokenomics is Initializable, PausableUpgradeable, UUPSUpgradeable, AccessManagedUpgradeable {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using SafeERC20 for IERC20Metadata;

    /// @notice The token contract being managed
    IERC20Metadata public token;
    /// @notice The timestamp when the token generation event (TGE) occurred
    uint256 public tgeTime;
    /// @notice The total supply of tokens
    uint256 public totalSupply;

    /// @notice Structure representing a group of tokens with specific release parameters
    /// @param id Unique identifier for the release group
    /// @param title Human-readable name for the release group
    /// @param initialLockedTokens Amount of tokens initially locked
    /// @param cliffDays Number of days before tokens start vesting
    /// @param vestingDays Number of days over which tokens vest
    /// @param lockedTokens Current amount of tokens still locked
    /// @param receiver Address that will receive the unlocked tokens
    struct TokenReleaseGroup {
        bytes32 id;
        string title;
        uint256 initialLockedTokens;
        uint256 cliffDays;
        uint256 vestingDays;
        uint256 lockedTokens;
        address receiver;
    }

    /// @notice Mapping of release group IDs to their details
    mapping(bytes32 => TokenReleaseGroup) private tokenReleaseGroupsByID;
    /// @notice Set of all release group IDs
    EnumerableSet.Bytes32Set private tokenReleaseGroupIDs;
    /// @notice Counter for generating unique release group IDs
    uint256 private nonce;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initializes the tokenomics contract
    /// @param token_ The address of the token contract
    /// @param totalSupply_ The total supply of tokens
    function initialize(address token_, uint256 totalSupply_) public initializer {
        __Pausable_init();
        __UUPSUpgradeable_init();
        __AccessManaged_init(msg.sender);

        nonce = 0;

        // make sure that the token looks sane
        require(token_ != address(0), "invalid token address");
        token = IERC20Metadata(token_);

        totalSupply = totalSupply_;
        require(totalSupply > 0, "invalid token total supply");

        // create different release groups
        _initializeGroups();
    }

    /// @notice Transfers unlocked tokens for all release groups
    function transferUnlockedTokens() external restricted {
        for (uint256 i = 0; i < tokenReleaseGroupIDs.length(); ++i) {
            transferUnlockedTokensForReleaseGroup(tokenReleaseGroupIDs.at(i));
        }
    }

    /// @notice Initializes predefined token release groups
    function _initializeGroups() internal {
        uint256 decimals = token.decimals();
        _addTokenReleaseGroup("Scout Nodes - Earning", 13147832000 * (10 ** decimals), 90, 1095, address(0));
        _addTokenReleaseGroup("Scout Nodes - NFT Staking", 6480000000 * (10 ** decimals), 90, 1095, address(0));
        _addTokenReleaseGroup("Scout Nodes - Seedify Airdrop", 372168000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("NFT airdrop - Staking rewards", 760000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("NFT airdrop - at tge based on snapshot", 760000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("Farmers, Byte streak, Chests, Early Rewards", 880000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("Future airdrops", 2400000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("Liquidity", 800000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("Ecosystem Growth", 800000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("Treasury", 1200000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("Advisors and investors", 7272000000 * (10 ** decimals), 0, 0, address(0));
        _addTokenReleaseGroup("Team", 5128000000 * (10 ** decimals), 0, 0, address(0));
    }

    /// @notice Transfers unlocked tokens for a specific release group
    /// @param id The ID of the release group
    function transferUnlockedTokensForReleaseGroup(bytes32 id) public restricted {
        TokenReleaseGroup storage group = tokenReleaseGroupsByID[id];

        uint256 remainingLockedTokens = _getRemainingTokensForGroup(id);
        require(group.lockedTokens >= remainingLockedTokens, "less tokens locked than expected");
        uint256 tokensToRelease = group.lockedTokens - remainingLockedTokens;
        group.lockedTokens = remainingLockedTokens;

        if (tokensToRelease > 0 && group.receiver != address(0)) {
            token.safeTransfer(group.receiver, tokensToRelease);
        }
    }

    /// @notice Generates a new unique ID for a token release group
    /// @return A unique bytes32 ID
    function _newTokenReleaseGroupId() internal returns (bytes32) {
        return keccak256(abi.encodePacked(block.timestamp, nonce++));
    }

    /// @notice Adds a new token release group
    /// @param title The name of the release group
    /// @param lockedTokens The amount of tokens to lock
    /// @param cliffDays The number of days before tokens start vesting
    /// @param vestingDays The number of days over which tokens vest
    /// @param receiver The address that will receive the unlocked tokens
    function _addTokenReleaseGroup(
        string memory title,
        uint256 lockedTokens,
        uint256 cliffDays,
        uint256 vestingDays,
        address receiver
    ) internal {
        bytes32 id = _newTokenReleaseGroupId();
        tokenReleaseGroupsByID[id] = TokenReleaseGroup(id, title, lockedTokens, cliffDays, vestingDays, lockedTokens, receiver);
        tokenReleaseGroupIDs.add(id);
    }

    /// @notice Calculates the remaining locked tokens for a release group
    /// @param id The ID of the release group
    /// @return The amount of tokens still locked
    function _getRemainingTokensForGroup(bytes32 id) internal view returns (uint256) {
        TokenReleaseGroup storage group = tokenReleaseGroupsByID[id];

        uint256 daysSinceTGE = (block.timestamp - tgeTime) / 60 / 60 / 24;

        // if we did not reach the cliff yet, no tokens should be unlocked
        if (group.cliffDays > daysSinceTGE) {
            return group.initialLockedTokens;
        }

        uint256 daysAfterCliff = daysSinceTGE - group.cliffDays;

        // if we passed the vesting period already, all tokens have to be unlocked
        if (daysAfterCliff >= group.vestingDays) {
            return 0;
        }

        // if we are in the middle of the vesting period, a proportional part of the tokens has to be unlocked
        uint256 remainingDaysOfVesting = group.vestingDays - daysAfterCliff;
        uint256 remaingLockedTokens = (group.initialLockedTokens * remainingDaysOfVesting) / group.vestingDays;

        return remaingLockedTokens;
    }

    /// @notice Sets the token generation event (TGE) timestamp
    /// @param time The timestamp of the TGE
    function setTGETime(uint256 time) external restricted {
        tgeTime = time;
    }

    /// @notice Sets the receiver address for a token release group
    /// @param id The ID of the release group
    /// @param receiver The new receiver address
    function setTokenReleaseGroupReceiverAddress(bytes32 id, address receiver) external restricted {
        require(tokenReleaseGroupIDs.contains(id), "token release group does not exist");
        TokenReleaseGroup storage group = tokenReleaseGroupsByID[id];
        group.receiver = receiver;
    }

    /// @notice Sets the cliff period for a token release group
    /// @param id The ID of the release group
    /// @param cliffDays The new cliff period in days
    function setTokenReleaseGroupCliff(bytes32 id, uint256 cliffDays) external restricted {
        require(tokenReleaseGroupIDs.contains(id), "token release group does not exist");
        TokenReleaseGroup storage group = tokenReleaseGroupsByID[id];
        group.cliffDays = cliffDays;
    }

    /// @notice Sets the vesting period for a token release group
    /// @param id The ID of the release group
    /// @param vestingDays The new vesting period in days
    function setTokenReleaseGroupVesting(bytes32 id, uint256 vestingDays) external restricted {
        require(tokenReleaseGroupIDs.contains(id), "token release group does not exist");
        TokenReleaseGroup storage group = tokenReleaseGroupsByID[id];
        group.vestingDays = vestingDays;
    }

    /// @notice Sets the title for a token release group
    /// @param id The ID of the release group
    /// @param title The new title
    function setTokenReleaseGroupTitle(bytes32 id, string calldata title) external restricted {
        require(tokenReleaseGroupIDs.contains(id), "token release group does not exist");
        TokenReleaseGroup storage group = tokenReleaseGroupsByID[id];
        group.title = title;
    }

    /// @notice Returns the total number of token release groups
    /// @return The number of release groups
    function getTokenReleaseGroupsCount() external view returns (uint256) {
        return tokenReleaseGroupIDs.length();
    }

    /// @notice Returns the amount of tokens released for a specific group
    /// @param groupId The ID of the release group
    /// @return The amount of tokens released
    function getReleasedTokens(bytes32 groupId) external view returns (uint256) {
        require(tokenReleaseGroupIDs.contains(groupId), "token release group does not exist");
        TokenReleaseGroup storage group = tokenReleaseGroupsByID[groupId];

        return group.initialLockedTokens - group.lockedTokens;
    }

    /// @notice Returns a paginated list of token release groups
    /// @param offset The starting index for pagination
    /// @param limit The maximum number of groups to return
    /// @return An array of token release groups
    function getTokenReleaseGroups(uint256 offset, uint256 limit) public view returns (TokenReleaseGroup[] memory) {
        require(limit <= 100, "Limit must be smaller than or equal 100");
        uint256 dataLength = tokenReleaseGroupIDs.length();
        if (dataLength == 0) {
            return new TokenReleaseGroup[](0);
        }
        require(offset < dataLength, "Offset larger than delegations");

        if (offset + limit > dataLength) {
            limit = dataLength - offset;
        }

        TokenReleaseGroup[] memory result = new TokenReleaseGroup[](limit);

        for (uint256 i = offset; i < offset + limit; ++i) {
            bytes32 id = tokenReleaseGroupIDs.at(i);
            TokenReleaseGroup storage data = tokenReleaseGroupsByID[id];
            result[i - offset] = data;
        }

        return result;
    }

    /// @notice Returns the current version of the contract
    /// @return The version number
    function version() external pure returns (uint256) {
        return 1;
    }

    /// @notice Pauses the contract
    function pause() external restricted {
        _pause();
    }

    /// @notice Unpauses the contract
    function unpause() external restricted {
        _unpause();
    }

    /// @notice Checks if the caller has permission to upgrade the contract
    function hasUpgradePermission() public restricted {}

    /// @notice Internal function to authorize contract upgrades
    function _authorizeUpgrade(address) internal override {
        hasUpgradePermission();
    }
}
