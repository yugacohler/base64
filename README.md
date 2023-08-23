# Base64
This is the repository for Base64, a smart contract framework for Tournament-based prediction markets.

It is built using [Foundry](https://book.getfoundry.sh/).

## Live Contract Addresses
On Base Goerli:

- [StaticOracleTournament](https://goerli.basescan.org/address/0xC09DF9Cb1A95835e49861e2a40711f7483978656)
- [StaticCompetitorProvider](https://goerli.basescan.org/address/0x50F809a2cEDEEBe99728d5Ca45CC15a39FE59ca3)
- [OracleResultProvider](https://goerli.basescan.org/address/0x6DE9cF0947a539Ac38CC7a8821955ED43715c305)

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

See the `script` folder for a sequence of scripts to deploy Base64 on Base Goerli.

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
