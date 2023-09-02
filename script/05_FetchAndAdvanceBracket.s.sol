// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {LibString} from "../lib/solmate/src/utils/LibString.sol";
import {OracleResultProvider} from "../src/results/OracleResultProvider.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {StaticOracleTournament} from "../src/tournaments/StaticOracleTournament.sol";
import {console2} from "../lib/forge-std/src/console2.sol";

// A script to fetch the bracket in a Base64 Tournament and advance it
// randomly.
// Usage: forge script ./script/05_FetchAndAdvanceBracket.s.sol:FetchAndAdvanceBracket \
// --broadcast --rpc-url "https://goerli.base.org/" \
// --private-key <private-key>
contract FetchAndAdvanceBracket is Script {
    function run() public {
        address tAddr = 0x6DE9cF0947a539Ac38CC7a8821955ED43715c305;
        address oAddr = 0x50F809a2cEDEEBe99728d5Ca45CC15a39FE59ca3;

        StaticOracleTournament t = StaticOracleTournament(tAddr);

        uint256[][] memory bracket  = t.getBracket();

        uint256 curRound = 0;
        while (bracket[curRound].length != 0) {
          curRound++;
        }

        uint256[] memory winners = new uint256[](bracket[curRound - 1].length / 2);
        uint256[] memory losers = new uint256[](bracket[curRound - 1].length / 2);
        string[] memory metadata = new string[](bracket[curRound - 1].length / 2);

        console2.log("Current round", curRound);

        for (uint256 i = 0; i < bracket[curRound - 1].length; i += 2) {
          uint256 competitor1 = bracket[curRound - 1][i];
          uint256 competitor2 = bracket[curRound - 1][i + 1];
          
          uint256 result = uint256(keccak256(abi.encodePacked(block.timestamp, competitor1, competitor2))) % 2;

          uint256 winner;
          uint256 loser;

          if (result == 0) {
              winner = competitor1;
              loser = competitor2;
          } else {
              winner = competitor2;
              loser = competitor1;
          }
          

          winners[i / 2] = winner;
          losers[i / 2] = loser;
          metadata[i / 2] = string(abi.encodePacked("Winner: ", LibString.toString(winner), " Loser: ", LibString.toString(loser)));

          console2.log("Winner", winner);
        }

        vm.startBroadcast();

        OracleResultProvider o = OracleResultProvider(oAddr);
        o.writeResults(winners, losers, metadata);
        t.advance();
        vm.stopBroadcast();
    }
}
