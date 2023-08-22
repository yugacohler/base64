// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBase64} from "../IBase64.sol";
import {ResultProvider} from "../ResultProvider.sol";

// A result provider that picks the result randomly.
contract RandomResultProvider is ResultProvider {
  ////////// MEMBER VARIABLES //////////

  // The random seed.
  uint256 _nonce;

  ////////// PUBLIC APIS //////////

  function getResult(uint256 competitor1, uint256 competitor2) external override returns (IBase64.Result memory) {
    uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _nonce))) % 2;
    _nonce++;

    uint256 winner;
    uint256 loser;

    if (random == 0) {
      winner = competitor1;
      loser = competitor2;
    } else {
      winner = competitor2;
      loser = competitor1;
    }
    
    return IBase64.Result({
      winnerId: winner,
      loserId: loser,
      metadata: ""
    });
  }
}
