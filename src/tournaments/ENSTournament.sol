// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "../CompetitorProvider.sol";
import {ResultProvider} from "../ResultProvider.sol";
import {ENSGate, ENS, ReverseRegistrar} from "../ens/ENS.sol";
import {Tournament} from "../Tournament.sol";

// A Tournament which only ENS holders can participate in.
contract ENSTournament is Tournament, ENSGate {
    ////////// CONSTRUCTOR //////////
    constructor(
        CompetitorProvider competitorProvider,
        ResultProvider resultProvider,
        ENS ens,
        ReverseRegistrar reverseRegistrar
    ) Tournament(competitorProvider, resultProvider) ENSGate(ENS(ens), ReverseRegistrar(reverseRegistrar)) {}

    ////////// PUBLIC APIS //////////

    function submitEntry(uint256[][] memory entry) public virtual override {
        require(hasENS(msg.sender), "NOT_ENS");
        super.submitEntry(entry);
    }
}
