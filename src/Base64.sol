// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBase64} from "./IBase64.sol";
import {Owned} from "../lib/solmate/src/auth/Owned.sol";

// Base64, a Smart Contract for Tournament-based pools.
contract Base64 is IBase64, Owned {
  event LogDebug(string message, uint256 data1, uint256 data2);
  ////////// CONSTANTS //////////
  
  // The entry fee.
  uint256 public constant ENTRY_FEE = 0.01 ether;

  ////////// MEMBER VARIABLES //////////

  // The State of Base64.
  State state = State.AcceptingEntries;

  // The mapping from team ID to team.
  mapping(uint256 => Team) teams;

  // The current bracket.
  uint256[][] bracket;

  // The mapping from participant address to entry.
  mapping(address => uint256[][]) entries;

  // The list of participants.
  Participant[] participants;

  // The mapping from participant address to participant.
  mapping(address => Participant) participantMap;

  // The number of rounds in the bracket.
  uint256 numRounds;

  // The current round of the bracket.
  uint256 curRound = 0;

  // The number of points awarded for each match in the current round.
  uint256 pointsPerMatch = 1;

  // A nonce used for picking winners.
  uint256 nonce = 0;

  ////////// CONSTRUCTOR //////////

  // Initializes the Base64 bracket with the given teams.
  // The number of teams must be a power of two between 4 and 256 inclusive.
  constructor(uint32[] memory teamIDs, string[] memory teamNames) Owned(msg.sender) {
    require(isPowerOfTwo(teamIDs.length), "INVALID_BRACKET_SIZE");
    require(teamIDs.length == teamNames.length, "INVALID_TEAM_DATA");
    require(checkTeamIDs(teamIDs), "INVALID_TEAM_IDS");

    // Initialize the teams.
    for (uint256 i = 0; i < teamNames.length; i++) {
      teams[teamIDs[i]] = Team(teamIDs[i], teamNames[i]);
    }

    // Initialize the bracket.
    uint256 teamsLeft = teamNames.length;

    while (teamsLeft >= 1) {
      bracket.push();
      if (teamsLeft > 1) {
        numRounds++;
      }

      teamsLeft /= 2;
    }

    // Initialize the first round of the bracket.
    for (uint256 i = 0; i < teamNames.length; i++) {
      bracket[0].push(teamIDs[i]);
    }    
  }

  ////////// PUBLIC APIS //////////

  function getBracket() override external view returns (uint256[][] memory) {
    return bracket;
  }

  function getTeam(uint256 teamId) override external view returns (Team memory) {
    require(teams[teamId].id != 0, "TEAM_NOT_FOUND");

    return teams[teamId];
  }

  function submitEntry(uint256[][] memory entry) override payable external {
    require(msg.value >= ENTRY_FEE, "INVALID_ENTRY_FEE");
    require(entries[msg.sender].length == 0, "ALREADY_SUBMITTED");
    validateEntry(entry);

    entries[msg.sender] = entry;

    Participant memory p = Participant(msg.sender, 0, 0);

    participants.push(p);
    participantMap[msg.sender] = p;
  }

  function getEntry(address addr) override external view returns (uint256[][] memory) {
    require(entries[addr].length > 0, "ENTRY_NOT_FOUND");

    return entries[addr];
  }

  function getState() override external view returns (State) {
    return state;
  }

  function getParticipants() override external view returns (Participant[] memory) {
    return participants;
  }
  
  function collectPayout() override external {
    require(state == State.Finished, "TOURNAMENT_NOT_FINISHED");
    require(participantMap[msg.sender].payout > 0, "NO_PAYOUT");

    payable(msg.sender).transfer(participantMap[msg.sender].payout);
  }

    ////////// ADMIN APIS //////////

  // Advances the state of Base64.
  function advance() external onlyOwner {
    if (state == State.AcceptingEntries) {
      state = State.InProgress;
      advanceRound();
    }
  }

  ////////// PRIVATE HELPERS //////////

  // Returns true if a number is a power of 2 greater than 4 and less than 256.
  function isPowerOfTwo(uint256 x) private pure returns (bool) {
      return x >= 4 && x <= 256 && (x & (x - 1)) == 0;
  }

  // Returns true if the team IDs are unique and valid.
  function checkTeamIDs(uint32[] memory teamIDs) private pure returns (bool) {
      for (uint256 i = 0; i < teamIDs.length; i++) {
          for (uint256 j = i + 1; j < teamIDs.length; j++) {
              if (teamIDs[i] == teamIDs[j]) {
                  return false;
              } else if (teamIDs[i] == 0) {
                  // Team IDs must be greater than 0.
                  return false;
              }
          }
      }

      return true;
  }

  // Validates an entry. To save on gas, we just ensure the entry has the proper number
  // of rounds and picks, without checking the team IDs.
  function validateEntry(uint256[][] memory entry) private view {
    require(entry.length == numRounds, "INVALID_NUM_ROUNDS");

    uint256 numTeams = bracket[0].length;

    for (uint32 i = 0; i < entry.length; i++) {
        numTeams /= 2;

        require(entry[i].length == numTeams, "INVALID_NUM_TEAMS");
    }
  }

  // Advances the bracket to the next round.
  function advanceRound() private {
    require(state == State.InProgress, "TOURNAMENT_NOT_IN_PROGRESS");
    require(curRound < numRounds, "TOURNAMENT_FINISHED");

    uint256 numWinners = bracket[curRound].length / 2;

    for (uint256 i = 0; i < numWinners; i++) {
      emit LogDebug("Picking winner for round and match", curRound, i);
      uint256 winner = pickWinner(bracket[curRound][i * 2], bracket[curRound][(i * 2) + 1]);
      bracket[curRound + 1].push(winner);
    }

    updatePoints();

    pointsPerMatch *= 2;
    curRound++;
  }

  // Randomly picks a winner between two team IDs.
  function pickWinner(uint256 teamID1, uint256 teamID2) private returns (uint256) {
    uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 2;
    nonce++;
    
    if (random == 0) {
      return teamID1;
    } else {
      return teamID2;
    }
  }

  // Updates the participants' points according to the current bracket and the participants'
  // entries.
  function updatePoints() private {
    for (uint256 i = 0; i < participants.length; i++) {
      uint256[][] memory entry = entries[participants[i].addr];

      // Score the entry for the current round.
      for (uint256 j = 0; j < bracket[curRound + 1].length; j ++) {
        if (bracket[curRound + 1][j] == entry[curRound][j]) {
          participants[i].points += pointsPerMatch;
        }
      }
    }
  }  
}
