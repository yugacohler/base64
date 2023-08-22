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

// Unit tests for a StaticOracleTournament.
contract StaticOracleTournamentTest is Test {
    Tournament _t;
    OracleResultProvider _o;

    uint256[][] _entry1;
    address _participant1;

    // Fallback function for this contract.
    receive() external payable {}

    // Modifier for tests that are invoked by a participant.
    modifier asParticipant() {
        vm.startPrank(_participant1);
        _;
        vm.stopPrank();
    }

    function setUp() public {
        uint256[] memory competitorIDs = new uint256[](8);
        for (uint8 i = 0; i < competitorIDs.length; i++) {
            competitorIDs[i] = i + 1;
        }

        string[] memory competitorURLs = new string[](8);
        competitorURLs[0] = "Brian.com";
        competitorURLs[1] = "Greg.com";
        competitorURLs[2] = "Alesia.com";
        competitorURLs[3] = "Manish.com";
        competitorURLs[4] = "LJ.com";
        competitorURLs[5] = "Paul.com";
        competitorURLs[6] = "Emilie.com";
        competitorURLs[7] = "Will.com";

        _o = new OracleResultProvider(address(this));
        _t = new StaticOracleTournament(competitorIDs, competitorURLs, _o);

        _participant1 = address(0x420);

        _entry1 = new uint256[][](3);
        _entry1[0] = new uint256[](4);
        _entry1[1] = new uint256[](2);
        _entry1[2] = new uint256[](1);

        _entry1[0][0] = 1;
        _entry1[0][1] = 3;
        _entry1[0][2] = 5;
        _entry1[0][3] = 7;
        _entry1[1][0] = 1;
        _entry1[1][1] = 5;
        _entry1[2][0] = 1;

        // Fund the address needed.
        vm.deal(address(_participant1), 1 ether);
    }

    function testGetBracketInitial() public asParticipant {
        uint256[][] memory bracket = _t.getBracket();

        assertEq(bracket.length, 4);

        assertEq(bracket[0].length, 8);
        assertEq(bracket[0][0], 1);
        assertEq(bracket[0][1], 2);
        assertEq(bracket[0][2], 3);
        assertEq(bracket[0][3], 4);
        assertEq(bracket[0][4], 5);
        assertEq(bracket[0][5], 6);
        assertEq(bracket[0][6], 7);
        assertEq(bracket[0][7], 8);

        assertEq(bracket[1].length, 0);
        assertEq(bracket[2].length, 0);
        assertEq(bracket[3].length, 0);
    }

    function testGetCompetitor() public asParticipant {
        Tournament.Competitor memory competitor = _t.getCompetitor(1);

        assertEq(competitor.id, 1);
        assertEq(competitor.uri, "Brian.com");
    }

    function testGetCompetitorNotFound() public asParticipant {
        vm.expectRevert("INVALID_ID");

        _t.getCompetitor(9);
    }

    function testSubmitEntry() public asParticipant {
        _t.submitEntry(_entry1);
    }

    function testSubmitEntryAlreadySubmitted() public {
        vm.prank(_participant1);
        _t.submitEntry(_entry1);

        vm.expectRevert("ALREADY_SUBMITTED");

        vm.prank(_participant1);
        _t.submitEntry(_entry1);
    }

    function testSubmitEntryInvalidNumRounds() public asParticipant {
        uint256[][] memory invalidEntry = new uint256[][](2);
        invalidEntry[0] = new uint256[](4);
        invalidEntry[1] = new uint256[](1);

        invalidEntry[0][0] = 1;
        invalidEntry[0][1] = 3;
        invalidEntry[0][2] = 5;
        invalidEntry[0][3] = 7;
        invalidEntry[1][0] = 1;

        vm.expectRevert("INVALID_NUM_ROUNDS");

        _t.submitEntry(invalidEntry);
    }

    function testSubmitEntryInvalidNumCompetitors() public asParticipant {
        uint256[][] memory invalidEntry = new uint256[][](3);
        invalidEntry[0] = new uint256[](4);
        invalidEntry[1] = new uint256[](3); // This needs to be 2.
        invalidEntry[2] = new uint256[](1);

        invalidEntry[0][0] = 1;
        invalidEntry[0][1] = 3;
        invalidEntry[0][2] = 5;
        invalidEntry[0][3] = 7;
        invalidEntry[1][0] = 1;
        invalidEntry[1][1] = 5;
        invalidEntry[2][0] = 1;

        vm.expectRevert("INVALID_NUM_TEAMS");

        _t.submitEntry(invalidEntry);
    }

    function testGetEntry() public asParticipant {
        _t.submitEntry(_entry1);

        uint256[][] memory entry = _t.getEntry(address(_participant1));

        assertEq(entry.length, _entry1.length);
        assertEq(entry[0].length, _entry1[0].length);
        assertEq(entry[1].length, _entry1[1].length);
        assertEq(entry[2].length, _entry1[2].length);

        assertEq(entry[0][0], _entry1[0][0]);
        assertEq(entry[0][1], _entry1[0][1]);
        assertEq(entry[0][2], _entry1[0][2]);
        assertEq(entry[0][3], _entry1[0][3]);
        assertEq(entry[1][0], _entry1[1][0]);
        assertEq(entry[1][1], _entry1[1][1]);
        assertEq(entry[2][0], _entry1[2][0]);
    }

    function testGetEntryNotFound() public asParticipant {
        vm.expectRevert("ENTRY_NOT_FOUND");

        _t.getEntry(address(this));
    }

    function testGetState() public asParticipant {
        assertTrue(_t.getState() == Tournament.State.AcceptingEntries);
    }

    function testListParticipants() public asParticipant {
        _t.submitEntry(_entry1);

        address[] memory participants = _t.listParticipants();

        assertEq(participants.length, 1);
        assertEq(participants[0], address(_participant1));
    }

    function testAdvanceRoundWithoutResults() public {
        vm.expectRevert("NO_SUCH_MATCH");

        _t.advance();
    }

    function testAdvanceRoundWithResults() public {
      uint256[] memory winners = new uint256[](4);
      winners[0] = 1;
      winners[1] = 3;
      winners[2] = 5;
      winners[3] = 7;

      uint256[] memory losers = new uint256[](4);
      losers[0] = 2;
      losers[1] = 4;
      losers[2] = 6;
      losers[3] = 8;

      string[] memory metadata = new string[](4);
      metadata[0] = "match1";
      metadata[1] = "match2";
      metadata[2] = "match3";
      metadata[3] = "match4";

      _o.writeResults(winners, losers, metadata);
      _t.advance();

      uint256[][] memory bracket = _t.getBracket();

      assertEq(bracket[1].length, 4);
      assertEq(bracket[1][0], 1);
      assertEq(bracket[1][1], 3);
      assertEq(bracket[1][2], 5);
      assertEq(bracket[1][3], 7);
    }

    // function testAdvanceRoundNotOwner() public asParticipant {
    //     vm.expectRevert("UNAUTHORIZED");

    //     _t.advance();
    // }

    // function testTwoParticipants() public {
    //     vm.prank(_participant1);
    //     _t.submitEntry(_entry1);

    //     // Submit another entry from address 0x1337.
    //     address participant2 = address(0x1337);
    //     vm.deal(address(participant2), 1 ether);

    //     uint256[][] memory entry2 = new uint256[][](3);
    //     entry2[0] = new uint256[](4);
    //     entry2[1] = new uint256[](2);
    //     entry2[2] = new uint256[](1);

    //     // The opposite entry of the first entry.
    //     entry2[0][0] = 2;
    //     entry2[0][1] = 4;
    //     entry2[0][2] = 6;
    //     entry2[0][3] = 8;
    //     entry2[1][0] = 2;
    //     entry2[1][1] = 6;
    //     entry2[2][0] = 2;

    //     // Send the entry from 0x1337.
    //     vm.prank(address(participant2));
    //     _t.submitEntry(entry2);

    //     // Advance the round.
    //     _t.advance();

    //     // The points of the two participants should add up to 4.
    //     address[] memory participants = _t.listParticipants();
    //     assertEq(participants.length, 2);

    //     Tournament.Participant memory p1 = _t.getParticipant(participants[0]);
    //     Tournament.Participant memory p2 = _t.getParticipant(participants[1]);

    //     assertTrue(p1.addr == address(_participant1) || p1.addr == address(0x1337));
    //     assertTrue(p2.addr == address(participant2) || p2.addr == address(0x1337));
    //     assertEq(p1.points + p2.points, 4);

    //     // Advance the round twice more. No errors.
    //     _t.advance();

    //     uint256[][] memory bracket = _t.getBracket();
    //     assertEq(bracket[2].length, 2);
    //     assertTrue(bracket[2][0] >= 1 && bracket[2][0] <= 4);
    //     assertTrue(bracket[2][1] >= 5 && bracket[2][1] <= 8);

    //     _t.advance();

    //     bracket = _t.getBracket();
    //     assertEq(bracket[3].length, 1);
    //     assertTrue(bracket[3][0] >= 1 && bracket[3][0] <= 8);

    //     // Expect a revert if we try to advance once more.
    //     vm.expectRevert("TOURNAMENT_FINISHED");
    //     _t.advance();
    // }
}
