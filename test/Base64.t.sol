// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Base64} from "../src/Base64.sol";
import {IBase64} from "../src/IBase64.sol";
import {Test} from "../lib/forge-std/src/Test.sol";
import {console2} from "../lib/forge-std/src/console2.sol";

// Unit tests for Base64.
contract Base64Test is Test {
    Base64 b;

    uint256[][] entry1;
    address participant1;

    // Fallback function for this contract.
    receive() external payable {}

    // Modifier for tests that are invoked by a participant.
    modifier asParticipant() {
        vm.startPrank(participant1);
        _;
        vm.stopPrank();
    }

    function setUp() public {
        uint32[] memory teamIDs = new uint32[](8);
        for (uint8 i = 0; i < teamIDs.length; i++) {
            teamIDs[i] = i + 1;
        }

        string[] memory teamNames = new string[](8);
        teamNames[0] = "Brian";
        teamNames[1] = "Greg";
        teamNames[2] = "Alesia";
        teamNames[3] = "Manish";
        teamNames[4] = "LJ";
        teamNames[5] = "Paul";
        teamNames[6] = "Emilie";
        teamNames[7] = "Will";

        b = new Base64(teamIDs, teamNames);

        participant1 = address(0x420);

        entry1 = new uint256[][](3);
        entry1[0] = new uint256[](4);
        entry1[1] = new uint256[](2);
        entry1[2] = new uint256[](1);

        entry1[0][0] = 1;
        entry1[0][1] = 3;
        entry1[0][2] = 5;
        entry1[0][3] = 7;
        entry1[1][0] = 1;
        entry1[1][1] = 5;
        entry1[2][0] = 1;

        // Fund the address needed.
        vm.deal(address(participant1), 1 ether);
    }

    function testConstructor_tooShort() public {
        uint32[] memory invalidTeamIDs = new uint32[](3);
        for (uint8 i = 0; i < invalidTeamIDs.length; i++) {
            invalidTeamIDs[i] = i + 1;
        }

        string[] memory invalidTeamNames = new string[](3);
        invalidTeamNames[0] = "Brian";
        invalidTeamNames[1] = "Greg";
        invalidTeamNames[2] = "Alesia";

        vm.expectRevert("INVALID_BRACKET_SIZE");

        new Base64(invalidTeamIDs, invalidTeamNames);
    }

    function testConstructor_notPowerOfTwo() public {
        uint32[] memory invalidTeamIDs = new uint32[](5);
        for (uint8 i = 0; i < invalidTeamIDs.length; i++) {
            invalidTeamIDs[i] = i + 1;
        }

        string[] memory invalidTeamNames = new string[](5);
        invalidTeamNames[0] = "Brian";
        invalidTeamNames[1] = "Greg";
        invalidTeamNames[2] = "Alesia";
        invalidTeamNames[3] = "Manish";
        invalidTeamNames[4] = "LJ";

        vm.expectRevert("INVALID_BRACKET_SIZE");

        new Base64(invalidTeamIDs, invalidTeamNames);
    }

    function testConstructor_notEnoughNames() public {
        uint32[] memory invalidTeamIDs = new uint32[](8);
        for (uint8 i = 0; i < invalidTeamIDs.length; i++) {
            invalidTeamIDs[i] = i + 1;
        }

        string[] memory invalidTeamNames = new string[](4);
        invalidTeamNames[0] = "Brian";
        invalidTeamNames[1] = "Greg";
        invalidTeamNames[2] = "Alesia";
        invalidTeamNames[3] = "Manish";

        vm.expectRevert("INVALID_TEAM_DATA");

        new Base64(invalidTeamIDs, invalidTeamNames);
    }

    function testConstructor_duplicateTeamIDs() public {
        uint32[] memory invalidTeamIDs = new uint32[](4);
        for (uint8 i = 0; i < invalidTeamIDs.length; i++) {
            invalidTeamIDs[i] = i + 1;
        }

        invalidTeamIDs[1] = 0;

        string[] memory invalidTeamNames = new string[](4);
        invalidTeamNames[0] = "Brian";
        invalidTeamNames[1] = "Greg";
        invalidTeamNames[2] = "Alesia";
        invalidTeamNames[3] = "Manish";

        vm.expectRevert("INVALID_TEAM_IDS");

        new Base64(invalidTeamIDs, invalidTeamNames);
    }

    function testConstructor_zeroValueID() public {
        uint32[] memory invalidTeamIDs = new uint32[](4);
        for (uint8 i = 0; i < invalidTeamIDs.length; i++) {
            invalidTeamIDs[i] = i;
        }

        invalidTeamIDs[1] = 0;

        string[] memory invalidTeamNames = new string[](4);
        invalidTeamNames[0] = "Brian";
        invalidTeamNames[1] = "Greg";
        invalidTeamNames[2] = "Alesia";
        invalidTeamNames[3] = "Manish";

        vm.expectRevert("INVALID_TEAM_IDS");

        new Base64(invalidTeamIDs, invalidTeamNames);
    }

    function testGetBracket_initial() public asParticipant {
        uint256[][] memory bracket = b.getBracket();

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

    function testGetTeam() public asParticipant {
        Base64.Team memory team = b.getTeam(1);

        assertEq(team.id, 1);
        assertEq(team.name, "Brian");
    }

    function testGetTeam_notFound() public asParticipant {
        vm.expectRevert("TEAM_NOT_FOUND");

        b.getTeam(9);
    }

    function testSubmitEntry() public asParticipant {
        b.submitEntry{value: 0.01 ether}(entry1);
    }

    function testSubmitEntry_alreadySubmitted() public {
        vm.prank(participant1);
        b.submitEntry{value: 0.01 ether}(entry1);

        vm.expectRevert("ALREADY_SUBMITTED");

        vm.prank(participant1);
        b.submitEntry{value: 0.01 ether}(entry1);
    }

    function testSubmitEntry_noFee() public asParticipant {
        vm.expectRevert("INVALID_ENTRY_FEE");

        b.submitEntry(entry1);
    }

    function testSubmitEntry_invalidNumRounds() public asParticipant {
        uint256[][] memory invalidEntry = new uint256[][](2);
        invalidEntry[0] = new uint256[](4);
        invalidEntry[1] = new uint256[](1);

        invalidEntry[0][0] = 1;
        invalidEntry[0][1] = 3;
        invalidEntry[0][2] = 5;
        invalidEntry[0][3] = 7;
        invalidEntry[1][0] = 1;

        vm.expectRevert("INVALID_NUM_ROUNDS");

        b.submitEntry{value: 0.01 ether}(invalidEntry);
    }

    function testSubmitEntry_invalidNumTeams() public asParticipant {
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

        b.submitEntry{value: 0.01 ether}(invalidEntry);
    }

    function testGetEntry() public asParticipant {
        b.submitEntry{value: 0.01 ether}(entry1);

        uint256[][] memory entry = b.getEntry(address(participant1));

        assertEq(entry.length, entry1.length);
        assertEq(entry[0].length, entry1[0].length);
        assertEq(entry[1].length, entry1[1].length);
        assertEq(entry[2].length, entry1[2].length);

        assertEq(entry[0][0], entry1[0][0]);
        assertEq(entry[0][1], entry1[0][1]);
        assertEq(entry[0][2], entry1[0][2]);
        assertEq(entry[0][3], entry1[0][3]);
        assertEq(entry[1][0], entry1[1][0]);
        assertEq(entry[1][1], entry1[1][1]);
        assertEq(entry[2][0], entry1[2][0]);
    }

    function testGetEntry_notFound() public asParticipant {
        vm.expectRevert("ENTRY_NOT_FOUND");

        b.getEntry(address(this));
    }

    function testGetState() public asParticipant {
        assertTrue(b.getState() == IBase64.State.AcceptingEntries);
    }

    function testListParticipants() public asParticipant {
        b.submitEntry{value: 0.01 ether}(entry1);

        address[] memory participants = b.listParticipants();

        assertEq(participants.length, 1);
        assertEq(participants[0], address(participant1));
    }

    function testAdvanceRound() public {
        b.advance();

        assertTrue(b.getState() == IBase64.State.InProgress);

        uint256[][] memory bracket = b.getBracket();

        assertEq(bracket[1].length, 4);
        assertTrue(bracket[1][0] == 1 || bracket[1][0] == 2);
        assertTrue(bracket[1][1] == 3 || bracket[1][1] == 4);
        assertTrue(bracket[1][2] == 5 || bracket[1][2] == 6);
        assertTrue(bracket[1][3] == 7 || bracket[1][3] == 8);
    }

    function testAdvanceRound_notOwner() public asParticipant {
        vm.expectRevert("UNAUTHORIZED");

        b.advance();
    }

    function testTwoParticipants() public {
        vm.prank(participant1);
        b.submitEntry{value: 0.01 ether}(entry1);

        // Submit another entry from address 0x1337.
        address participant2 = address(0x1337);
        vm.deal(address(participant2), 1 ether);

        uint256[][] memory entry2 = new uint256[][](3);
        entry2[0] = new uint256[](4);
        entry2[1] = new uint256[](2);
        entry2[2] = new uint256[](1);

        // The opposite entry of the first entry.
        entry2[0][0] = 2;
        entry2[0][1] = 4;
        entry2[0][2] = 6;
        entry2[0][3] = 8;
        entry2[1][0] = 2;
        entry2[1][1] = 6;
        entry2[2][0] = 2;

        // Send the entry from 0x1337.
        vm.prank(address(participant2));
        b.submitEntry{value: 0.01 ether}(entry2);

        // Advance the round.
        b.advance();

        // The points of the two participants should add up to 4.
        address[] memory participants = b.listParticipants();
        assertEq(participants.length, 2);

        IBase64.Participant memory p1 = b.getParticipant(participants[0]);
        IBase64.Participant memory p2 = b.getParticipant(participants[1]);

        assertTrue(p1.addr == address(participant1) || p1.addr == address(0x1337));
        assertTrue(p2.addr == address(participant2) || p2.addr == address(0x1337));
        assertEq(p1.points + p2.points, 4);

        // Advance the round twice more. No errors.
        b.advance();

        uint256[][] memory bracket = b.getBracket();
        assertEq(bracket[2].length, 2);
        assertTrue(bracket[2][0] >= 1 && bracket[2][0] <= 4);
        assertTrue(bracket[2][1] >= 5 && bracket[2][1] <= 8);

        b.advance();

        bracket = b.getBracket();
        assertEq(bracket[3].length, 1);
        assertTrue(bracket[3][0] >= 1 && bracket[3][0] <= 8);

        // Expect a revert if we try to advance once more.
        vm.expectRevert("TOURNAMENT_FINISHED");
        b.advance();

        // Collect payout for the first participant.
        vm.prank(address(participant1));
        b.collectPayout();

        // Can't collect payout twice.
        vm.prank(address(participant1));
        vm.expectRevert("INSUFFICIENT_BALANCE");
        b.collectPayout();

        // Collect payout for the second participant.
        vm.prank(address(participant2));
        b.collectPayout();

        // Balance of the two addresses should add up to 0.02 ether.
        console2.log("Participant 1 balance", address(participant1).balance);
        console2.log("Participant 2 balance", address(participant2).balance);
    }
}
