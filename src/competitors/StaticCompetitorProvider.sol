// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../CompetitorProvider.sol";
import {IBase64} from "../IBase64.sol";

// A competitor provider for static competitors.
contract StaticCompetitorProvider is CompetitorProvider {
    ////////// MEMBER VARIABLES //////////

    // The IDs of the competitors.
    uint256[] ids;

    // The mapping from competitor ID to metadata URI.
    mapping (uint256 => string) metadataURIs;
    
    ////////// CONSTRUCTOR //////////

    constructor(uint256[] memory _ids, string[] memory _uri) {
      require(_ids.length >= 4 && _ids.length <= 256, "INVALID_NUM_IDS");
      require(_uri.length == _ids.length, "INVALID_NUM_URIS");
      
      // Determine the relevant power of 2 for the number of competitors,
      // rather than doing expensive logarithm arithmetic.
      uint256 powerOfTwo = 4;
      
      if (_ids.length < 8) {
        powerOfTwo = 4;
      } else if (_ids.length < 16 && _ids.length >= 8) {
        powerOfTwo = 8;
      } else if (_ids.length < 32) {
        powerOfTwo = 16;
      } else if (_ids.length < 64) {
        powerOfTwo = 32;
      } else if (_ids.length < 128) {
        powerOfTwo = 64;
      } else if (_ids.length < 256) {
        powerOfTwo = 128;
      } else {
        powerOfTwo = 256;
      }
    
      for (uint16 i = 0; i < powerOfTwo; i++) {
        require(_ids[i] != 0, "ZERO_ID");
        ids.push(_ids[i]);
        
        // Fail if there was a duplicate ID.
        require(bytes(metadataURIs[_ids[i]]).length == 0, "DUPLICATE_IDS");
        metadataURIs[_ids[i]] = _uri[i];
      }    
    }

    ////////// PUBLIC APIS //////////
    
    function listCompetitorIDs() external view override returns (uint256[] memory) {
      return ids;
    }

    function getCompetitor(uint256 competitorId) external view override returns (IBase64.Competitor memory) {
      require(bytes(metadataURIs[competitorId]).length != 0, "INVALID_ID");
      return IBase64.Competitor(competitorId, metadataURIs[competitorId]);
    }
}
