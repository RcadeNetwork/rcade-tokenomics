# Solidity API

## Tokenomics

Manages token release schedules and vesting for different groups

_Implements a flexible token release system with cliff and vesting periods_

### token

```solidity
contract IERC20Metadata token
```

The token contract being managed

### tgeTime

```solidity
uint256 tgeTime
```

The timestamp when the token generation event (TGE) occurred

### totalSupply

```solidity
uint256 totalSupply
```

The total supply of tokens

### TokenReleaseGroup

Structure representing a group of tokens with specific release parameters

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |

```solidity
struct TokenReleaseGroup {
  bytes32 id;
  string title;
  uint256 initialLockedTokens;
  uint256 cliffDays;
  uint256 vestingDays;
  uint256 lockedTokens;
  address receiver;
}
```

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address token_, uint256 totalSupply_) public
```

Initializes the tokenomics contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| token_ | address | The address of the token contract |
| totalSupply_ | uint256 | The total supply of tokens |

### transferUnlockedTokens

```solidity
function transferUnlockedTokens() external
```

Transfers unlocked tokens for all release groups

### _initializeGroups

```solidity
function _initializeGroups() internal
```

Initializes predefined token release groups

### transferUnlockedTokensForReleaseGroup

```solidity
function transferUnlockedTokensForReleaseGroup(bytes32 id) public
```

Transfers unlocked tokens for a specific release group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | bytes32 | The ID of the release group |

### _newTokenReleaseGroupId

```solidity
function _newTokenReleaseGroupId() internal returns (bytes32)
```

Generates a new unique ID for a token release group

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes32 | A unique bytes32 ID |

### _addTokenReleaseGroup

```solidity
function _addTokenReleaseGroup(string title, uint256 lockedTokens, uint256 cliffDays, uint256 vestingDays, address receiver) internal
```

Adds a new token release group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| title | string | The name of the release group |
| lockedTokens | uint256 | The amount of tokens to lock |
| cliffDays | uint256 | The number of days before tokens start vesting |
| vestingDays | uint256 | The number of days over which tokens vest |
| receiver | address | The address that will receive the unlocked tokens |

### _getRemainingTokensForGroup

```solidity
function _getRemainingTokensForGroup(bytes32 id) internal view returns (uint256)
```

Calculates the remaining locked tokens for a release group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | bytes32 | The ID of the release group |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The amount of tokens still locked |

### setTGETime

```solidity
function setTGETime(uint256 time) external
```

Sets the token generation event (TGE) timestamp

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| time | uint256 | The timestamp of the TGE |

### setTokenReleaseGroupReceiverAddress

```solidity
function setTokenReleaseGroupReceiverAddress(bytes32 id, address receiver) external
```

Sets the receiver address for a token release group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | bytes32 | The ID of the release group |
| receiver | address | The new receiver address |

### setTokenReleaseGroupCliff

```solidity
function setTokenReleaseGroupCliff(bytes32 id, uint256 cliffDays) external
```

Sets the cliff period for a token release group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | bytes32 | The ID of the release group |
| cliffDays | uint256 | The new cliff period in days |

### setTokenReleaseGroupVesting

```solidity
function setTokenReleaseGroupVesting(bytes32 id, uint256 vestingDays) external
```

Sets the vesting period for a token release group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | bytes32 | The ID of the release group |
| vestingDays | uint256 | The new vesting period in days |

### setTokenReleaseGroupTitle

```solidity
function setTokenReleaseGroupTitle(bytes32 id, string title) external
```

Sets the title for a token release group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | bytes32 | The ID of the release group |
| title | string | The new title |

### getTokenReleaseGroupsCount

```solidity
function getTokenReleaseGroupsCount() external view returns (uint256)
```

Returns the total number of token release groups

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The number of release groups |

### getReleasedTokens

```solidity
function getReleasedTokens(bytes32 groupId) external view returns (uint256)
```

Returns the amount of tokens released for a specific group

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| groupId | bytes32 | The ID of the release group |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The amount of tokens released |

### getTokenReleaseGroups

```solidity
function getTokenReleaseGroups(uint256 offset, uint256 limit) public view returns (struct Tokenomics.TokenReleaseGroup[])
```

Returns a paginated list of token release groups

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| offset | uint256 | The starting index for pagination |
| limit | uint256 | The maximum number of groups to return |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | struct Tokenomics.TokenReleaseGroup[] | An array of token release groups |

### version

```solidity
function version() external pure returns (uint256)
```

Returns the current version of the contract

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The version number |

### pause

```solidity
function pause() external
```

Pauses the contract

### unpause

```solidity
function unpause() external
```

Unpauses the contract

### hasUpgradePermission

```solidity
function hasUpgradePermission() public
```

Checks if the caller has permission to upgrade the contract

### _authorizeUpgrade

```solidity
function _authorizeUpgrade(address) internal
```

Internal function to authorize contract upgrades

