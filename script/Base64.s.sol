// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
// import {Base64} from "../src/Base64.sol";

contract Base64Script is Script {
    uint32[] _teamIDs;
    string[] _teamNames;

    function setUp() public {
        _teamIDs = new uint32[](8);
        for (uint8 i = 0; i < _teamIDs.length; i++) {
            _teamIDs[i] = i + 1;
        }

        _teamNames = new string[](8);
        _teamNames[0] = "Brian";
        _teamNames[1] = "Greg";
        _teamNames[2] = "Alesia";
        _teamNames[3] = "Manish";
        _teamNames[4] = "LJ";
        _teamNames[5] = "Paul";
        _teamNames[6] = "Emilie";
        _teamNames[7] = "Will";
    }

    function run() public {
        vm.startBroadcast();

        // new Base64(_teamIDs, _teamNames);

        vm.stopBroadcast();
    }
}
