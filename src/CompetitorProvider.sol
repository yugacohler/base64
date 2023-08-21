// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBase64} from "./IBase64.sol";

// An interface that provides the list of competitors, their IDs, and their URIs.
interface CompetitorProvider {
    // Lists the IDs of the competitors. This must return an array that is of a power of 2,
    // between 4 and 256 inclusive.
    function listCompetitorIDs() external view returns (uint256[] memory);

    // Returns the competitor for the given competitor ID.
    function getCompetitor(uint256) external view returns (IBase64.Competitor memory);
}
