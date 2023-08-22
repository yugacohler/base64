// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../CompetitorProvider.sol";
import {ERC721} from "../../lib/solmate/src/tokens/ERC721.sol";
import {IBase64} from "../IBase64.sol";
import {Strings} from "../../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

// A competitor provider for FriendTech competitors.
contract FriendTechCompetitorProvider is CompetitorProvider {
  ////////// CONSTANTS //////////

  // The base URI for FriendTech metadata.
  string public constant BASE_URI = "https://prod-api.kosetto.com/users/";

  ////////// MEMBER VARIABLES //////////

  // The map from FriendTech ID to FriendTech wallet address.
  mapping (uint256 => address) _addresses;

  ////////// CONSTRUCTOR //////////

  constructor(address[] memory addresses) {
    uint256 powerOfTwo = _getPowerOfTwo(addresses.length);

    for (uint16 i = 0; i < powerOfTwo; i++) {
      require(addresses[i] != address(0), "ZERO_ID");
      uint256 id = uint256(uint160(addresses[i]));
      _ids.push(id);

      // Fail if there was a duplicate ID.
      require(_addresses[id] == address(0), "DUPLICATE_IDS");
      _addresses[id] = addresses[i];
    }
  }
  
  ////////// PUBLIC APIS //////////  

  function listCompetitorIDs() external view override returns (uint256[] memory) {
    return _ids;
  }

  function getCompetitor(uint256 competitorId) external view override returns (IBase64.Competitor memory) {
    require(_addresses[competitorId] != address(0), "INVALID_ID");

    return IBase64.Competitor({
      id: competitorId,
      uri: string(abi.encodePacked(BASE_URI, Strings.toHexString(_addresses[competitorId])))
    });
  }
}
