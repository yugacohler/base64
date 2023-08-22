// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../CompetitorProvider.sol";
import {ERC721} from "../../lib/solmate/src/tokens/ERC721.sol";
import {IBase64} from "../IBase64.sol";

// A competitor provider for ERC-721 competitors.
contract ERC721CompetitorProvider is CompetitorProvider {
  ////////// MEMBER VARIABLES //////////

  // The underlying ERC721.
  ERC721 _erc721;

  ////////// CONSTRUCTOR //////////

  constructor(address erc721, uint256[] memory ids) {
    uint256 powerOfTwo = _getPowerOfTwo(_ids.length);

    for (uint16 i = 0; i < powerOfTwo; i++) {
      require(ids[i] != 0, "ZERO_ID");
      _ids.push(ids[i]);
    }

    _erc721 = ERC721(erc721); 
  }
  
  ////////// PUBLIC APIS //////////  

  function listCompetitorIDs() external view override returns (uint256[] memory) {
    return _ids;
  }

  function getCompetitor(uint256 competitorId) external view override returns (IBase64.Competitor memory) {
    require(_erc721.ownerOf(competitorId) != address(0), "INVALID_ID");

    return IBase64.Competitor({
      id: competitorId,
      uri: _erc721.tokenURI(competitorId)
    });
  }
}
