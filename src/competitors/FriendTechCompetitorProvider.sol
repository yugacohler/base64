// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../CompetitorProvider.sol";
import {ERC721} from "../../lib/solmate/src/tokens/ERC721.sol";
import {IBase64} from "../IBase64.sol";

// A competitor provider for FriendTech competitors.
contract FriendTechCompetitorProvider is CompetitorProvider {
  ////////// MEMBER VARIABLES //////////

  // The map from FriendTech ID to FriendTech wallet address.
  mapping (uint256 => address) public addresses;

  ////////// CONSTRUCTOR //////////

  constructor(uint256[] memory _ids, address[] memory _addresses) {
    require(_ids.length == _addresses.length, "INVALID_NUM_ADDRESSES");

    uint256 powerOfTwo = getPowerOfTwo(_ids.length);

    for (uint16 i = 0; i < powerOfTwo; i++) {
      require(_ids[i] != 0, "ZERO_ID");
      ids.push(_ids[i]);

      // Fail if there was a duplicate ID.
      require(addresses[_ids[i]] == address(0), "DUPLICATE_IDS");
      addresses[_ids[i]] = _addresses[i];
    }
  }
  
  ////////// PUBLIC APIS //////////  

  function listCompetitorIDs() external view override returns (uint256[] memory) {
    return ids;
  }

  function getCompetitor(uint256 competitorId) external view override returns (IBase64.Competitor memory) {
    require(addresses[competitorId] != address(0), "INVALID_ID");

    return IBase64.Competitor({
      id: competitorId,
      uri: "" // TODO
    });
  }
}
