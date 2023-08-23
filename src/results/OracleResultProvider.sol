// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Owned} from "../../lib/solmate/src/auth/Owned.sol";
import {ResultProvider} from "../ResultProvider.sol";
import {Tournament} from "../Tournament.sol";

// A result provider that acts as an oracle to determine the result of a match.
contract OracleResultProvider is ResultProvider, Owned {
    ////////// MEMBER VARIABLES //////////

    // The mapping of competitor ID to competitor ID to the winning ID.
    // The first competitor ID is aways less than the second competitor ID.
    mapping(uint256 => mapping(uint256 => uint256)) _results;

    // The mapping of competitor ID to competitor ID to the metadata of the match.
    // The first competitor ID is aways less than the second competitor ID.
    mapping(uint256 => mapping(uint256 => string)) _metadata;

    ////////// CONSTRUCTOR //////////
    constructor(address owner) Owned(owner) {}

    ////////// PUBLIC APIS //////////
    function getResult(uint256 competitor1, uint256 competitor2)
        public
        view
        override
        returns (Tournament.Result memory)
    {
        uint256 smallerId = competitor1 < competitor2 ? competitor1 : competitor2;
        uint256 biggerId = competitor1 < competitor2 ? competitor2 : competitor1;

        // Competitor IDs are non-zero.
        require(_results[smallerId][biggerId] != 0, "NO_SUCH_MATCH");

        return Tournament.Result({
            winnerId: _results[smallerId][biggerId],
            loserId: _results[smallerId][biggerId] == smallerId ? biggerId : smallerId,
            metadata: _metadata[smallerId][biggerId]
        });
    }

    ////////// ADMIN APIS //////////

    // Writes a batch of match results.
    function writeResults(uint256[] memory winners, uint256[] memory losers, string[] memory metadata)
        public
        onlyOwner
    {
        require(winners.length == losers.length, "COMPETITOR_MISMATCH");
        require(winners.length == metadata.length, "METADATA_MISMATCH");

        for (uint256 i = 0; i < winners.length; i++) {
            uint256 smallerId = winners[i] < losers[i] ? winners[i] : losers[i];
            uint256 biggerId = winners[i] < losers[i] ? losers[i] : winners[i];

            _results[smallerId][biggerId] = winners[i];
            _metadata[smallerId][biggerId] = metadata[i];
        }
    }
}
