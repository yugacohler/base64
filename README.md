# Base64

Base64 is a smart contract framework for Tournament-based prediction markets that was built for Coinbase's 
[Onchain Summer](https://www.onchainsummer.xyz) Hackathon. It was built using [Foundry](https://book.getfoundry.sh)
by [Yuga Cohler](https://github.com/yugacohler) and [Chris Nascone](https://github.com/cnasc).

> **NOTE:** These contracts are unaudited and potentially buggy. Use at your own risk!

https://github.com/yugacohler/base64/assets/11857268/0ee3cb35-3f94-43c7-9053-143bbdbd9b29

(The above video uses random competitors and random results.)

## Key Concepts
A **Tournament** is the central smart contract of Base64. It consists of:
- **Competitors**: The entities that compete in the tournament. These can be anything, e.g. [ERC-721 tokens](./src/competitors/ERC721CompetitorProvider.sol), or [FriendTech accounts](./src/competitors/FriendTechCompetitorProvider.sol). The number of 
competitors must be a power of 2 between 4 and 256 inclusive.
- **Results**: The mechanism for deciding the winner of any given match in the Tournament. This could be anything, e.g.
[random](./src/results/RandomResultProvider.sol), or based on [price](./src/results/FriendTechResultProvider.sol).
- **Participants**: These are the onchain addresses that predict the results of the Tournament. There could be
conditions on them, for example, [that they are ENS holders](./src/ens/ENSGate.sol).

The Participant with the most points at the end of the Tournament wins.

> **NOTE**: Base64 does not accept bets/stakes and does not compute payouts to participants. However, a separate Escrow contract
> that depends on Base64 could be deployed to enable this functionality. Do so at your own risk!

## Frontend 

Coming soon!

## Live Contract Addresses
On Base Goerli:

- [StaticOracleTournament](https://goerli.basescan.org/address/0xd1d9eB6b0eE9B06979f0989A6eb998d3D0566058)
- [StaticCompetitorProvider](https://goerli.basescan.org/address/0x3b7c292A1ec5B440b2fD913D430ABfC9785d9838)
- [OracleResultProvider](https://goerli.basescan.org/address/0xC9E588781658b71D271435E70C849D6914608eb2)

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
