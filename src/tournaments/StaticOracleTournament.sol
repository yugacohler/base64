// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "..//CompetitorProvider.sol";
import {Owned} from "../../lib/solmate/src/auth/Owned.sol";
import {ResultProvider} from "../ResultProvider.sol";
import {CompetitorProvider} from "../CompetitorProvider.sol";
import {StaticCompetitorProvider} from "../competitors/StaticCompetitorProvider.sol";
import {OracleResultProvider} from "../results/OracleResultProvider.sol";
import {SafeTransferLib} from "../../lib/solmate/src/utils/SafeTransferLib.sol";
import {Tournament} from "../Tournament.sol";

// A Tournament in which the competitors are statically defined, and the results
// are defined by an oracle.
contract StaticOracleTournament is Tournament {
    ////////// CONSTRUCTOR //////////
    constructor(uint256[] memory ids, string[] memory uris)
        Tournament(new StaticCompetitorProvider(ids, uris), new OracleResultProvider(msg.sender))
    {}
}
