// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {StaticCompetitorProvider} from "../src/competitors/StaticCompetitorProvider.sol";
import {Tournament} from "../src/Tournament.sol";

// A script to deploy a StaticCompetitorProvider with FriendTech JSON data.
contract StaticFriendTechCompetitors is Script {
    bytes _abiData;

    constructor() {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/data/friendtech_08222023_parsed.json");
        string memory json = vm.readFile(path);

        _abiData = vm.parseJson(json);
    }

    function run() public {
        Tournament.Competitor[] memory competitors = abi.decode(_abiData, (Tournament.Competitor[]));

        uint256[] memory ids = new uint256[](competitors.length);
        for (uint256 i = 0; i < competitors.length; i++) {
            ids[i] = competitors[i].id;
        }

        string[] memory uris = new string[](competitors.length);
        for (uint256 i = 0; i < competitors.length; i++) {
            uris[i] = competitors[i].uri;
        }

        vm.startBroadcast();

        new StaticCompetitorProvider(ids, uris);

        vm.stopBroadcast();
    }
}
