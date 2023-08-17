// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBase64} from "./IBase64.sol";

// Base64, a Smart Contract for Tournament-based pools.
contract Base64 is IBase64 {
  ////////// PUBLIC APIS //////////

  function getBracket() override external view returns (uint256[][] memory) {
    require(false, "NOT_IMPLEMENTED");
  }

  function getTeam(uint256 teamId) override external view returns (Team memory) {
    require(false, "NOT_IMPLEMENTED");
  }

  function submitEntry(uint256[][] memory entry) override external {
    require(false, "NOT_IMPLEMENTED");
  }

  function getEntry(address addr) override external view returns (uint256[][] memory) {
    require(false, "NOT_IMPLEMENTED");
  }

  function getState() override external view returns (State) {
    require(false, "NOT_IMPLEMENTED");
  }

  function getWinners() override external view returns (Participant[] memory) {
    require(false, "NOT_IMPLEMENTED");
  }
  
  function collectPayout() override external {
    require(false, "NOT_IMPLEMENTED");
  }
}
