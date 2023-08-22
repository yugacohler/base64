// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../CompetitorProvider.sol";
import {ITournament} from "../ITournament.sol";

// A competitor provider for static competitors.
contract StaticCompetitorProvider is CompetitorProvider {
    ////////// MEMBER VARIABLES //////////

    // The mapping from competitor ID to metadata URI.
    mapping (uint256 => string) _metadataURIs;
    
    ////////// CONSTRUCTOR //////////

    constructor(uint256[] memory ids, string[] memory uris) {
      require(uris.length == ids.length, "INVALID_NUM_URIS");

      uint256 powerOfTwo = _getPowerOfTwo(ids.length);
      
      for (uint16 i = 0; i < powerOfTwo; i++) {
        require(ids[i] != 0, "ZERO_ID");
        _ids.push(ids[i]);
        
        // Fail if there was a duplicate ID.
        require(bytes(_metadataURIs[ids[i]]).length == 0, "DUPLICATE_IDS");
        _metadataURIs[ids[i]] = uris[i];
      }    
    }

    ////////// PUBLIC APIS //////////
    
    function listCompetitorIDs() external view override returns (uint256[] memory) {
      return _ids;
    }

    function getCompetitor(uint256 competitorId) external view override returns (ITournament.Competitor memory) {
      require(bytes(_metadataURIs[competitorId]).length != 0, "INVALID_ID");
      return ITournament.Competitor(competitorId, _metadataURIs[competitorId]);
    }
}
