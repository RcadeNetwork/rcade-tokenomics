# Solidity API

## ReleasableToken

An ERC20 token with upgradeable functionality and access control

_Extends OpenZeppelin's ERC20, UUPS, and AccessManaged contracts_

### constructor

```solidity
constructor() public
```

### initialize

```solidity
function initialize(string name, string symbol) public
```

Initializes the token with name and symbol

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | The name of the token |
| symbol | string | The symbol of the token |

### mint

```solidity
function mint(address to, uint256 amount) public
```

Mints new tokens to the specified address

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to receive the minted tokens |
| amount | uint256 | The amount of tokens to mint |

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

