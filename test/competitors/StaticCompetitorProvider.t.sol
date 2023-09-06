// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../../src/CompetitorProvider.sol";
import {StaticCompetitorProvider} from "../../src/competitors/StaticCompetitorProvider.sol";
import {Test} from "../../lib/forge-std/src/Test.sol";

// Unit tests for StaticCompetitorProvider.
contract StaticCompetitorProviderTest is Test {
    CompetitorProvider _cp;

    function setUp() public {
        uint256[] memory competitorIDs = new uint256[](8);
        for (uint8 i = 0; i < competitorIDs.length; i++) {
            competitorIDs[i] = i + 1;
        }

        string[] memory competitorURLs = new string[](8);
        competitorURLs[0] = "Brian.com";
        competitorURLs[1] = "Greg.com";
        competitorURLs[2] = "Alesia.com";
        competitorURLs[3] = "Manish.com";
        competitorURLs[4] = "LJ.com";
        competitorURLs[5] = "Paul.com";
        competitorURLs[6] = "Emilie.com";
        competitorURLs[7] = "Will.com";

        _cp = new StaticCompetitorProvider(competitorIDs, competitorURLs);
    }

    function testConstructorTooShort() public {
        uint256[] memory invalidCompetitorIDs = new uint256[](3);
        for (uint8 i = 0; i < invalidCompetitorIDs.length; i++) {
            invalidCompetitorIDs[i] = i + 1;
        }

        string[] memory invalidCompetitorURLs = new string[](3);
        invalidCompetitorURLs[0] = "Brian.com";
        invalidCompetitorURLs[1] = "Greg.com";
        invalidCompetitorURLs[2] = "Alesia.com";

        vm.expectRevert("INVALID_NUM_IDS");

        new StaticCompetitorProvider(invalidCompetitorIDs, invalidCompetitorURLs);
    }

    function testConstructorNotEnoughURLs() public {
        uint256[] memory invalidCompetitorIDs = new uint256[](8);
        for (uint8 i = 0; i < invalidCompetitorIDs.length; i++) {
            invalidCompetitorIDs[i] = i + 1;
        }

        string[] memory invalidCompetitorURLs = new string[](4);
        invalidCompetitorURLs[0] = "Brian.com";
        invalidCompetitorURLs[1] = "Greg.com";
        invalidCompetitorURLs[2] = "Alesia.com";
        invalidCompetitorURLs[3] = "Manish";

        vm.expectRevert("INVALID_NUM_URIS");

        new StaticCompetitorProvider(invalidCompetitorIDs, invalidCompetitorURLs);
    }

    function testConstructorDuplicateCompetitorIDs() public {
        uint256[] memory invalidCompetitorIDs = new uint256[](4);
        for (uint8 i = 0; i < invalidCompetitorIDs.length; i++) {
            invalidCompetitorIDs[i] = i + 1;
        }

        invalidCompetitorIDs[1] = 3;

        string[] memory invalidCompetitorURLs = new string[](4);
        invalidCompetitorURLs[0] = "Brian.com";
        invalidCompetitorURLs[1] = "Greg.com";
        invalidCompetitorURLs[2] = "Alesia.com";
        invalidCompetitorURLs[3] = "Manish";

        vm.expectRevert("DUPLICATE_IDS");

        new StaticCompetitorProvider(invalidCompetitorIDs, invalidCompetitorURLs);
    }

    function testConstructorZeroValueID() public {
        uint256[] memory invalidCompetitorIDs = new uint256[](4);
        for (uint8 i = 0; i < invalidCompetitorIDs.length; i++) {
            invalidCompetitorIDs[i] = i;
        }

        invalidCompetitorIDs[1] = 0;

        string[] memory invalidCompetitorURLs = new string[](4);
        invalidCompetitorURLs[0] = "Brian.com";
        invalidCompetitorURLs[1] = "Greg.com";
        invalidCompetitorURLs[2] = "Alesia.com";
        invalidCompetitorURLs[3] = "Manish";

        vm.expectRevert("ZERO_ID");

        new StaticCompetitorProvider(invalidCompetitorIDs, invalidCompetitorURLs);
    }
}
