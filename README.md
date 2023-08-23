# Base64
This is the repository for Base64, a smart contract framework for Tournament-based prediction markets.

It is built using [Foundry](https://book.getfoundry.sh/).

## Contract Addresses
On Base Goerli:

- [StaticOracleTournament](https://goerli.basescan.org/address/0xf9344c79044F64c6A068e4E8eA4d92A2A91F7675)
- [StaticCompetitorProvider](https://goerli.basescan.org/address/0xfe423ee2386720a066AAb2349062b5594E086133)
- [OracleResultProvider](https://goerli.basescan.org/address/0xD3E14C73157144D0eCe2a57364AC2320d72aCB69)

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

### StaticFriendTechCompetitors
forge script ./script/01_StaticFriendTechCompetitors.s.sol:StaticFriendTechCompetitors \
  --broadcast --verify --rpc-url "https://goerli.base.org/" \
  --private-key <owner-private-key> \
  --verifier etherscan \
  --verifier-url "https://api-goerli.basescan.org/api" \
  --etherscan-api-key <etherscan-api-key>

### OracleResultProvider
Use the address of the deployer in `oracle_result_provider.data`:

```shell
forge create \
	--constructor-args-path ./data/oracle_result_provider.data \
	--verify \
	--verifier etherscan \
	--verifier-url "https://api-goerli.basescan.org/api" \
  --etherscan-api-key <etherscan-api-key> \
	--gas-limit 5000000 \
	--private-key <owner-private-key> \
	--rpc-url "https://goerli.base.org/" \
	./src/results/OracleResultProvider.sol:OracleResultProvider
```

### StaticOracleTournament
Use the OracleResultProvider address from above in `static_oracle_tournament.data`:

```shell
forge create \
	--constructor-args ./data/static_oracle_tournament.data \
	--verify \
	--verifier etherscan \
	--verifier-url "https://api-goerli.basescan.org/api" \
  --etherscan-api-key <etherscan-api-key> \
	--gas-limit 5000000 \
	--private-key <owner-private-key> \
	--rpc-url "https://goerli.base.org/" \
	./src/results/OracleResultProvider.sol:OracleResultProvider
```

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
