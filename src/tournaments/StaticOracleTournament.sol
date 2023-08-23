// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {StaticCompetitorProvider} from "../competitors/StaticCompetitorProvider.sol";
import {OracleResultProvider} from "../results/OracleResultProvider.sol";
import {Tournament} from "../Tournament.sol";

// A Tournament in which the competitors are statically defined, and the results
// are defined by an oracle.
contract StaticOracleTournament is Tournament {
    ////////// CONSTRUCTOR //////////
    constructor(StaticCompetitorProvider provider, OracleResultProvider oracle) Tournament(provider, oracle) {}
}
