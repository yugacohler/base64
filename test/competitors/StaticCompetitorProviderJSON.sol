// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Tournament} from "../../src/Tournament.sol";
import {CompetitorProvider} from "../../src/CompetitorProvider.sol";
import {ResultProvider} from "../../src/ResultProvider.sol";
import {StaticCompetitorProvider} from "../../src/competitors/StaticCompetitorProvider.sol";
import {OracleResultProvider} from "../../src/results/OracleResultProvider.sol";
import {RandomResultProvider} from "../../src/results/RandomResultProvider.sol";
import {Tournament} from "../../src/Tournament.sol";
import {StaticOracleTournament} from "../../src/tournaments/StaticOracleTournament.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";
import {console2} from "../../lib/forge-std/src/Console2.sol";

// Unit tests for a StaticCompetitorProvider with FriendTech JSON data.
contract StaticFriendTechTournamentTest is Test {
  StaticCompetitorProvider _s;
  bytes _abiData;

  function setUp() public {
    string memory root = vm.projectRoot();
    string memory path = string.concat(root, "/data/friendtech_08222023_parsed.json");
    string memory json = vm.readFile(path);

    _abiData = vm.parseJson(json);
    Tournament.Competitor[] memory competitors = abi.decode(_abiData, (Tournament.Competitor[]));

    uint256[] memory ids = new uint256[](competitors.length);
    for (uint256 i = 0; i < competitors.length; i++) {
      ids[i] = competitors[i].id;
    }

    string[] memory uris = new string[](competitors.length);
    for (uint256 i = 0; i < competitors.length; i++) {
      uris[i] = competitors[i].uri;
    }

    _s = new StaticCompetitorProvider(ids, uris);
  }

  function testListCompetitors() public {
    Tournament.Competitor[] memory competitors = abi.decode(_abiData, (Tournament.Competitor[]));

    uint256[] memory ids = _s.listCompetitorIDs();
    assertEq(ids.length, competitors.length);

    for (uint256 i = 0; i < ids.length; i++) {
      assertEq(ids[i], competitors[i].id);
    }
  }

  function testGetCompetitor() public {
    Tournament.Competitor[] memory competitors = abi.decode(_abiData, (Tournament.Competitor[]));

    for (uint256 i = 0; i < competitors.length; i++) {
      Tournament.Competitor memory c = _s.getCompetitor(competitors[i].id);
      assertEq(c.id, competitors[i].id);
      assertEq(c.uri, competitors[i].uri);
    }
  }
}
