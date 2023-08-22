// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../CompetitorProvider.sol";
import {ERC721} from "../../lib/solmate/src/tokens/ERC721.sol";
import {Tournament} from "../Tournament.sol";
import {Strings} from "../../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

// A competitor provider for FriendTech competitors.
contract FriendTechCompetitorProvider is CompetitorProvider {
    ////////// CONSTANTS //////////

    // The base URI for FriendTech metadata.
    string public constant BASE_URI = "https://prod-api.kosetto.com/users/";

    ////////// MEMBER VARIABLES //////////

    // The map from FriendTech ID to FriendTech wallet address.
    mapping(uint256 => address) public addresses;

    ////////// CONSTRUCTOR //////////

    constructor(address[] memory a) {
        uint256 powerOfTwo = _getPowerOfTwo(a.length);

        for (uint16 i = 0; i < powerOfTwo; i++) {
            require(a[i] != address(0), "ZERO_ID");
            uint256 id = uint256(uint160(a[i]));
            _ids.push(id);

            // Fail if there was a duplicate ID.
            require(addresses[id] == address(0), "DUPLICATE_IDS");
            addresses[id] = a[i];
        }
    }

    ////////// PUBLIC APIS //////////

    function listCompetitorIDs() external view override returns (uint256[] memory) {
        return _ids;
    }

    function getCompetitor(uint256 competitorId) external view override returns (Tournament.Competitor memory) {
        require(addresses[competitorId] != address(0), "INVALID_ID");

        return Tournament.Competitor({
            id: competitorId,
            uri: string(abi.encodePacked(BASE_URI, Strings.toHexString(addresses[competitorId])))
        });
    }
}
