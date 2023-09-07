// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {StaticOracleTournament} from "../src/tournaments/StaticOracleTournament.sol";

// A script to advance the bracket in a Base64 Tournament.
// Usage: forge script ./script/05_AdvanceBracket.s.sol:AdvanceBracket \
// --broadcast --rpc-url "https://goerli.base.org/" \
// --private-key <private-key> \
// --sig "run(address,address)" \
// <tournament>
contract AdvanceBracket is Script {
    function run(address tAddr) public {
        StaticOracleTournament t = StaticOracleTournament(tAddr);

        vm.startBroadcast();
        t.advance();
        vm.stopBroadcast();
    }
}
