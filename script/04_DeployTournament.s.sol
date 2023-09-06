// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {StaticCompetitorProvider} from "../src/competitors/StaticCompetitorProvider.sol";
import {OracleResultProvider} from "../src/results/OracleResultProvider.sol";
import {StaticOracleTournament} from "../src/tournaments/StaticOracleTournament.sol";
import {Tournament} from "../src/Tournament.sol";
import {console2} from "../lib/forge-std/src/console2.sol";

// A script to deploy the competitors in a Base64 Tournament.
// Usage: forge script ./script/04_DeployTournament.s.sol:DeployTournament \
// --broadcast --verify --rpc-url "https://goerli.base.org/" \
// --private-key <private-key> \
// --verifier etherscan \
// --verifier-url "https://api-goerli.basescan.org/api" \
// --etherscan-api-key <etherscan-api-key> \
// --sig "run(address,address)" \
// <competitor-provider> <result-provider>
contract DeployTournament is Script {
    function run(address s, address o) public {
        StaticCompetitorProvider scp = StaticCompetitorProvider(s);
        OracleResultProvider orp = OracleResultProvider(o);

        vm.startBroadcast();

        StaticOracleTournament t = new StaticOracleTournament(scp, orp);

        console2.log("Tournament", address(t));

        vm.stopBroadcast();
    }
}
