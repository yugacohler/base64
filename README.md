# Base64
This is the repository for Base64, a smart contract for Tournament-based betting pools.

It is built using [Foundry](https://book.getfoundry.sh/).

## Build

```shell
$ forge build
```

## Test

```shell
$ forge test
```

## Format

```shell
$ forge fmt
```

## Gas Snapshots

```shell
$ forge snapshot
```

## Start Local Ethereum Network
Start a local Ethereum Network by running

```shell
$ anvil
```

## Deploy Base64
The command below uses a default private key of Anvil and the Anvil RPC:

```shell
$ forge script script/Base64.s.sol:Base64Script --broadcast --verify --rpc-url http://127.0.0.1:8545
```

The output will display the contract address.

## Call Base64

### getBracket
```shell
cast call <contract-address> "getBracket()(uint256[][])"
```

