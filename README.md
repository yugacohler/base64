# Base64
This is the repository for Base64, a smart contract for Tournament-based prediction markets.

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
$ forge script script/Base64.s.sol:Base64Script \
  --broadcast --verify --rpc-url "https://goerli.base.org/" \
  --private-key <admin-private-key>
```

The output will display the contract address.

## Call Base64

### getBracket
```shell
cast call <contract-address> "getBracket()(uint256[][])"
```

### getTeam
```shell
cast call <contract-address> "getTeam(uint256)((uint256,string))" 1
```

### submitEntry
Use another private key for this transaction.
```shell
cast send \
  --value 0.01ether \
  --private-key <other-private-key> \
  <contract-address> \
  "submitEntry(uint256[][])" "[[1,3,5,7],[3,5],[3]]"
```

### getParticipant
```shell
cast call <contract-address> "listParticipants()(address[])"
```

### advance
```shell
cast send --private-key <admin-private-key> \
  --rpc-url "https://goerli.base.org/" \
  --gas-limit 5000000 \
  <contract-address> "advance()"
```
