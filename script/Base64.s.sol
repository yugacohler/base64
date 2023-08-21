// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
// import {Base64} from "../src/Base64.sol";

contract Base64Script is Script {
    uint32[] teamIDs;
    string[] teamNames;

    function setUp() public {
        teamIDs = new uint32[](8);
        for (uint8 i = 0; i < teamIDs.length; i++) {
            teamIDs[i] = i + 1;
        }

        teamNames = new string[](8);
        teamNames[0] = "Brian";
        teamNames[1] = "Greg";
        teamNames[2] = "Alesia";
        teamNames[3] = "Manish";
        teamNames[4] = "LJ";
        teamNames[5] = "Paul";
        teamNames[6] = "Emilie";
        teamNames[7] = "Will";
    }

    function run() public {
        vm.startBroadcast();

        // new Base64(teamIDs, teamNames);

        vm.stopBroadcast();
    }
}
