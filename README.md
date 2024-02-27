## 1 Click AAVE Leverager

This system can be used as a library to help users leverage or deleverage their AAVE positions.

The contract omnichain address is: `0x82b3bcF54E2697BCad3fF3a8bb517064970D7345`

## Quick start

```
forge install
forge test --fork-url https://eth.llamarpc.com
```

## Mock deploy

This deployment script uses [CreateX](https://createx.rocks) to have the same deployment address on all chains.

### Ethereum mainnet

```
forge test --fork-url https://eth.llamarpc.com
forge script script/LeveragerDeploy.s.sol --fork-url https://eth.llamarpc.com
```

### Polygone

```
forge test --fork-url https://polygon.llamarpc.com
forge script script/LeveragerDeploy.s.sol --fork-url https://polygon.llamarpc.com
```
