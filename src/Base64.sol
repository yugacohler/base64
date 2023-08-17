// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBase64} from "./IBase64.sol";

// Base64, a Smart Contract for Tournament-based pools.
contract Base64 is IBase64 {
  ////////// PUBLIC APIS //////////

  // Returns the current state of the Tournament bracket. The first array index corresponds to 
  // the round number of the tournament. The second array index corresponds to the team number,
  // from top to bottom on the left, and then top to bottom on the right. The array contains the
  // team ID.
  function getBracket() override external view returns (uint256[][] memory) {
    require(false, "NOT_IMPLEMENTED");
  }

  // Returns the team for the given team ID.
  function getTeam(uint256 teamId) override external view returns (Team memory) {
    require(false, "NOT_IMPLEMENTED");
  }

  // Submits an entry to the Tournament pool. The entry must consist of N-1 rounds, where N
  // is the number of rounds in the Tournament. The entry must also pay the entry fee.
  // An address may submit at most one entry.
  function submitEntry(uint256[][] memory entry) override external {
    require(false, "NOT_IMPLEMENTED");
  }

  // Returns an entry for a given address.
  function getEntry(address addr) override external view returns (uint256[][] memory) {
    require(false, "NOT_IMPLEMENTED");
  }

  // Returns the state of the Tournament pool.
  function getState() override external view returns (State) {
    require(false, "NOT_IMPLEMENTED");
  }

  // Returns the winners of the Tournament pool. Only callable when the Tournament
  // is in the Finished state.
  function getWinners() override external view returns (Participant[] memory) {
    require(false, "NOT_IMPLEMENTED");
  }
  
  // Collects the payout to a winner. Only callable when the Tournament is in the
  // Finished state and if the caller is a winner.
  function collectPayout() override external {
    require(false, "NOT_IMPLEMENTED");
  }
}
