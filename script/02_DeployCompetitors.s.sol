// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {OracleResultProvider} from "../src/results/OracleResultProvider.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {StaticCompetitorProvider} from "../src/competitors/StaticCompetitorProvider.sol";
import {Tournament} from "../src/Tournament.sol";
import {console2} from "../lib/forge-std/src/console2.sol";

// A script to deploy a sample Base64 Tournament.
contract DeployCompetitors is Script {
    // A struct for the input data.
    struct InputData {
        uint256[] ids;
        string[] uris;
    }

    function run() public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/", "data/friendtech_parsed.data");
        string memory json = vm.readFile(path);
        bytes memory data = vm.parseJson(json);

        InputData memory inputData = abi.decode(data, (InputData));

        require(inputData.ids.length == inputData.uris.length, "ids and uris must be the same length");

        uint256[] memory ids = new uint256[](inputData.ids.length);
        for (uint256 i = 0; i < inputData.ids.length; i++) {
            ids[i] = inputData.ids[i];
        }

        string[] memory uris = new string[](inputData.uris.length);
        for (uint256 i = 0; i < inputData.uris.length; i++) {
            uris[i] = inputData.uris[i];
        }

        vm.startBroadcast();

        StaticCompetitorProvider scp = new StaticCompetitorProvider(ids, uris);

        console2.log("Competitors", address(scp));
        console2.log("This address", address(this));

        vm.stopBroadcast();
    }
}
