# Solidity API

## AccessManager

Manages access control and permissions for the tokenomics system

_Implements role-based access control for token and tokenomics operations_

### tokenomics

```solidity
contract Tokenomics tokenomics
```

The tokenomics contract being managed

### token

```solidity
contract ReleasableToken token
```

The token contract being managed

### ADMIN_USER

```solidity
uint64 ADMIN_USER
```

Role ID for administrative users

### TOKENOMICS_MAINTAINER

```solidity
uint64 TOKENOMICS_MAINTAINER
```

Role ID for tokenomics maintainers

### TOKENOMICS_RUNNER

```solidity
uint64 TOKENOMICS_RUNNER
```

Role ID for tokenomics runners

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(address tokenomics_, address token_) public
```

Initializes the access manager

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenomics_ | address | The address of the tokenomics contract |
| token_ | address | The address of the token contract |

### setRoles

```solidity
function setRoles(address target, bytes4[] selectors, uint64 roleId) external
```

Sets roles for specific function selectors on a target contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| target | address | The address of the target contract |
| selectors | bytes4[] | The function selectors to set roles for |
| roleId | uint64 | The role ID to assign |

### applyRoles

```solidity
function applyRoles() external
```

Applies predefined roles to tokenomics and token functions

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

