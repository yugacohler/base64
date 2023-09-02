// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "./CompetitorProvider.sol";
import {Owned} from "../lib/solmate/src/auth/Owned.sol";
import {ResultProvider} from "./ResultProvider.sol";

/**
 * ██████╗░░█████╗░░██████╗███████╗░█████╗░░░██╗██╗
 * ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔═══╝░░██╔╝██║
 * ██████╦╝███████║╚█████╗░█████╗░░██████╗░██╔╝░██║
 * ██╔══██╗██╔══██║░╚═══██╗██╔══╝░░██╔══██╗███████║
 * ██████╦╝██║░░██║██████╔╝███████╗╚█████╔╝╚════██║
 * ╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝░╚════╝░░░░░░╚═╝
 *
 *
 * A Smart Contract for Tournament-based prediction markets.
 */
abstract contract Tournament is Owned {
    ////////// STRUCTS AND ENUMS //////////

    // A struct representing a single competitor in the Tournament.
    struct Competitor {
        // The ID of the competitor.
        uint256 id;
        // The URI housing the metadata of the competitor.
        string uri;
    }

    // A struct representing a single match result in the Tournament.
    struct Result {
        // The ID of the winner of the match.
        uint256 winnerId;
        // The ID of the loser of the match.
        uint256 loserId;
        // A string representing any metadata about the match.
        string metadata;
    }

    // A struct representing a participant in the Tournament prediction market.
    struct Participant {
        // The address of the participant.
        address addr;
        // The points the participant has earned.
        uint256 points;
    }

    // An enum representing the state of the Tournament prediction market.
    enum State
    // The Tournament prediction market is accepting entries.
    {
        AcceptingEntries,
        // The Tournament is in progress and the prediction market is no longer accepting entries.
        InProgress,
        // The Tournament has concluded.
        Finished
    }

    ////////// MEMBER VARIABLES //////////

    // The State of Base64.
    State public state = State.AcceptingEntries;

    // The Competitor provider.
    CompetitorProvider _competitorProvider;

    // The match result provider.
    ResultProvider public resultProvider;

    // The current bracket.
    uint256[][] _bracket;

    // The mapping from participant address to entry.
    mapping(address => uint256[][]) _entries;

    // The mapping from participant address to participant.
    mapping(address => Participant) _participantMap;

    // The list of participant addresses.
    address[] _participants;

    // The number of rounds in the bracket.
    uint256 public numRounds;

    // The current round of the bracket, 0 indexed.
    uint256 public curRound = 0;

    // The number of points awarded for each match in the current round.
    uint256 _pointsPerMatch = 1;

    ////////// CONSTRUCTOR //////////

    // Initializes the Base64 bracket with the given competitors.
    // The number of competitors must be a power of two between 4 and 256 inclusive.
    constructor(CompetitorProvider cp, ResultProvider rp) Owned(msg.sender) {
        _competitorProvider = cp;
        resultProvider = rp;

        // Initialize the bracket.
        uint256[] memory competitorIDs = _competitorProvider.listCompetitorIDs();
        uint256 competitorsLeft = competitorIDs.length;

        while (competitorsLeft >= 1) {
            _bracket.push();
            if (competitorsLeft > 1) {
                numRounds++;
            }

            competitorsLeft /= 2;
        }

        // Initialize the first round of the bracket.
        for (uint256 i = 0; i < competitorIDs.length; i++) {
            _bracket[0].push(competitorIDs[i]);
        }
    }

    ////////// PUBLIC APIS //////////

    // Returns the current state of the Tournament bracket. The first array index corresponds to
    // the round number of the tournament. The second array index corresponds to the competitor number,
    // from top to bottom on the left, and then top to bottom on the right. The array contains the
    // competitor ID.
    function getBracket() external view virtual returns (uint256[][] memory) {
        return _bracket;
    }

    // Returns the competitor for the given competitor ID.
    function getCompetitor(uint256 competitorId) external view virtual returns (Competitor memory) {
        return _competitorProvider.getCompetitor(competitorId);
    }

    // Submits an entry to the Tournament prediction market. The entry must consist of N-1 rounds, where N
    // is the number of rounds in the Tournament. An address may submit at most one entry.
    function submitEntry(uint256[][] memory entry) public virtual {
        require(_entries[msg.sender].length == 0, "ALREADY_SUBMITTED");
        require(state == State.AcceptingEntries, "TOURNAMENT_NOT_ACCEPTING_ENTRIES");

        _validateEntry(entry);

        _entries[msg.sender] = entry;

        Participant memory p = Participant(msg.sender, 0);

        _participantMap[msg.sender] = p;
        _participants.push(msg.sender);
    }

    // Returns an entry for a given address.
    function getEntry(address addr) external view returns (uint256[][] memory) {
        require(_entries[addr].length > 0, "ENTRY_NOT_FOUND");

        return _entries[addr];
    }

    // Returns the state of the Tournament prediction market.
    function getState() external view returns (State) {
        return state;
    }

    // Returns the addresses of the participants in the tournament prediction market.
    function listParticipants() external view returns (address[] memory) {
        return _participants;
    }

    // Returns the participant for the given address.
    function getParticipant(address addr) external view returns (Participant memory) {
        require(_participantMap[addr].addr != address(0), "PARTICIPANT_NOT_FOUND");

        return _participantMap[addr];
    }

    ////////// ADMIN APIS //////////

    // Advances the state of Base64.
    function advance() external onlyOwner {
        require(state != State.Finished, "TOURNAMENT_FINISHED");

        if (state == State.AcceptingEntries) {
            state = State.InProgress;
            _advanceRound();
        } else if (state == State.InProgress) {
            _advanceRound();
        }
    }

    ////////// PRIVATE HELPERS //////////

    // Validates an entry. To save on gas, we just ensure the entry has the proper number
    // of rounds and picks, without checking the competitor IDs.
    function _validateEntry(uint256[][] memory entry) private view {
        require(entry.length == numRounds, "INVALID_NUM_ROUNDS");

        uint256 numCompetitors = _bracket[0].length;

        for (uint32 i = 0; i < entry.length; i++) {
            numCompetitors /= 2;

            require(entry[i].length == numCompetitors, "INVALID_NUM_TEAMS");
        }
    }

    // Advances the bracket to the next round.
    function _advanceRound() private {
        require(state == State.InProgress, "TOURNAMENT_NOT_IN_PROGRESS");
        require(curRound < numRounds, "TOURNAMENT_FINISHED");

        uint256 numWinners = _bracket[curRound].length / 2;

        for (uint256 i = 0; i < numWinners; i++) {
            Tournament.Result memory result =
                resultProvider.getResult(_bracket[curRound][i * 2], _bracket[curRound][(i * 2) + 1]);
            _bracket[curRound + 1].push(result.winnerId);
        }

        _updatePoints();

        _pointsPerMatch *= 2;
        curRound++;

        if (curRound >= numRounds) {
            state = State.Finished;
        }
    }

    // Updates the participants' points according to the current bracket and the participants'
    // entries.
    function _updatePoints() private {
        for (uint256 i = 0; i < _participants.length; i++) {
            uint256[][] memory entry = _entries[_participants[i]];

            // Score the entry for the current round.
            for (uint256 j = 0; j < _bracket[curRound + 1].length; j++) {
                if (_bracket[curRound + 1][j] == entry[curRound][j]) {
                    _participantMap[_participants[i]].points += _pointsPerMatch;
                }
            }
        }
    }
}
