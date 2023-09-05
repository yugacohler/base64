// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "../lib/forge-std/src/Script.sol";
import {StaticCompetitorProvider} from "../src/competitors/StaticCompetitorProvider.sol";
import {Tournament} from "../src/Tournament.sol";
import {console2} from "../lib/forge-std/src/console2.sol";

// A script to deploy the competitors in a Base64 Tournament.
// Usage: forge script ./script/02_DeployCompetitors.s.sol:DeployCompetitors \
// --broadcast --verify --rpc-url "https://goerli.base.org/" \
// --private-key <private-key> \
// --verifier etherscan \
// --verifier-url "https://api-goerli.basescan.org/api" \
// --etherscan-api-key <etherscan-api-key> \
// --sig "run(string)" \
// <file>
contract DeployCompetitors is Script {
    // A struct for the input data.
    struct InputData {
        uint256[] ids;
        string[] uris;
    }

    function run(string memory file) public {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/", file);
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

        vm.stopBroadcast();
    }
}
