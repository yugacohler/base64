# Base64

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Start Local Ethereum Network
Start a local Ethereum Network by running

```shell
$ anvil
```

### Deploy Base64
The command below uses a default private key of Anvil and the Anvil RPC:

```shell
$ forge script script/Base64.s.sol:Base64Script --broadcast --verify --rpc-url http://127.0.0.1:8545
```

The output will display the contract address.

### Call Base64
```shell
cast call <contract-address> "getBracket()(uint256[][])"
```
### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
