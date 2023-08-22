// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {FriendTech} from "./FriendTech.sol";
import {FriendTechCompetitorProvider} from "../competitors/FriendTechCompetitorProvider.sol";
import {Tournament} from "../Tournament.sol";
import {ResultProvider} from "../ResultProvider.sol";
import {Strings} from "../../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

// A result provider that picks the result based on the current price of the 
// FriendTech keys.
contract FriendTechResultProvider is ResultProvider {
  ////////// MEMBER VARIABLES //////////

  // The FriendTech contract.
  FriendTech _friendTech;

  // The FriendTech competitor provider contract.
  FriendTechCompetitorProvider _friendTechCompetitorProvider;

  ////////// CONSTRUCTOR //////////

  constructor(
    address friendTechAddress,
    address friendTechCompetitorProviderAddress
    ) {
    _friendTech = FriendTech(friendTechAddress);
    _friendTechCompetitorProvider = FriendTechCompetitorProvider(friendTechCompetitorProviderAddress);
  }

  ////////// PUBLIC APIS //////////

  function getResult(uint256 competitor1, uint256 competitor2) public view override returns (Tournament.Result memory) {
    address address1 = _friendTechCompetitorProvider.addresses(competitor1);
    require(address1 != address(0), "INVALID_ID");

    address address2 = _friendTechCompetitorProvider.addresses(competitor2);
    require(address2 != address(0), "INVALID_ID");

    uint256 price1 = _friendTech.getSellPrice(address1, 1);
    uint256 price2 = _friendTech.getSellPrice(address2, 1);

    uint256 winner;
    uint256 loser;
    string memory metadata = string(abi.encodePacked(Strings.toString(price1), ",", Strings.toString(price2)));

    if (price1 > price2) {
      winner = competitor1;
      loser = competitor2;
    } else {
      winner = competitor2;
      loser = competitor1;
    }
    
    return Tournament.Result({
      winnerId: winner,
      loserId: loser,
      metadata: metadata
    });
  }
}
