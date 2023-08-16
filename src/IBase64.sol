// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// The interface for Base64.
interface IBase64 {

  ////////// STRUCTS //////////

  // A struct representing a single team in the Tournament.
  struct Team {
    // The ID of the team.
    uint256 id;

    // The name of the team.
    string name;
  }

  ////////// PUBLIC APIS //////////

  // Returns the current state of the Tournament bracket. The first array index corresponds to 
  // the round number of the tournament. The second array index corresponds to the team number,
  // from top to bottom on the left, and then top to bottom on the right. The array contains the
  // team ID.
  function getBracket() external view returns (uint256[][] memory);

  // Returns the team for the given team ID.
  function getTeam(uint256 teamId) external view returns (Team memory);

  // Submits an entry to the Tournament pool. The entry must consist of N-1 rounds, where N
  // is the number of rounds in the Tournament. The entry must also pay the entry fee.
  // An address may submit at most one entry.
  function submitEntry(uint256[][] memory entry) external;

  // Gets an entry for a given address.
  function getEntry(address addr) external view returns (uint256[][] memory);
}
