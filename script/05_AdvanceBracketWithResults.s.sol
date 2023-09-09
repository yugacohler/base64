// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {LibString} from "../lib/solmate/src/utils/LibString.sol";
import {OracleResultProvider} from "../src/results/OracleResultProvider.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {StaticOracleTournament} from "../src/tournaments/StaticOracleTournament.sol";
import {console2} from "../lib/forge-std/src/console2.sol";

// A script to fetch the bracket in a Base64 Tournament and advance it
// randomly.
// Usage: forge script ./script/05_AdvanceBracketWithResults.s.sol:AdvanceBracketWithResults \
// --broadcast --rpc-url "https://goerli.base.org/" \
// --private-key <private-key> \
// --sig "run(address,address,string)" \
// <tournament> <result-provider> <results-file>
contract AdvanceBracketWithResults is Script {
  // A struct for the results data.
    struct ResultData {
        uint256[] winners;
        uint256[] losers;
    }

    function run(address tAddr, string memory resultsFile) public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/", resultsFile);
        string memory json = vm.readFile(path);
        bytes memory data = vm.parseJson(json);

        ResultData memory resultData = abi.decode(data, (ResultData));

        StaticOracleTournament t = StaticOracleTournament(tAddr);

        uint256[][] memory bracket = t.getBracket();

        uint256 curRound = 0;
        while (bracket[curRound].length != 0) {
            curRound++;
        }

        // string[] memory metadata = new string[](bracket[curRound - 1].length / 2);

        console2.log("Current round", curRound);

        for (uint256 i = 0; i < bracket[curRound - 1].length; i += 2) {
          uint256 winner = resultData.winners[i / 2];
          uint256 loser = resultData.losers[i / 2];
          if (winner == loser) {
            console2.log("ERROR: Winner and loser are the same", resultData.winners[i / 2]);
            return;
          }

          uint256 competitor1 = bracket[curRound - 1][i];
          uint256 competitor2 = bracket[curRound - 1][i + 1];
          
          if (winner != competitor1 && winner != competitor2) {
            console2.log("ERROR: Winner is not a competitor", winner, competitor1, competitor2);
            return;
          }

          if (loser != competitor1 && loser != competitor2) {
            console2.log("ERROR: Loser is not a competitor", loser, competitor1, competitor2);
            return;
          }

          console2.log("Winner of Match", i / 2, winner);
          console2.log("Loser of Match", i / 2, loser);
        }

        console2.log("Results validated!");

        // vm.startBroadcast();

        // OracleResultProvider o = OracleResultProvider(oAddr);
        // o.writeResults(winners, losers, metadata);
        // t.advance();
        // vm.stopBroadcast();
    }
}
