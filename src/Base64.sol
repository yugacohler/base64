// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IBase64} from "./IBase64.sol";
import {Owned} from "../lib/solmate/src/auth/Owned.sol";
import {SafeTransferLib} from "../lib/solmate/src/utils/SafeTransferLib.sol";

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
 * Right now, this is hard-coded to pick winners randomly.
 */
contract Base64 is IBase64, Owned {
    using SafeTransferLib for address;
    ////////// CONSTANTS //////////

    // The entry fee.
    uint256 public constant ENTRY_FEE = 0.01 ether;

    ////////// MEMBER VARIABLES //////////

    // The State of Base64.
    State state = State.AcceptingEntries;

    // The mapping from competitor ID to competitor.
    mapping(uint256 => Competitor) competitors;

    // The current bracket.
    uint256[][] bracket;

    // The mapping from participant address to entry.
    mapping(address => uint256[][]) entries;

    // The mapping from participant address to participant.
    mapping(address => Participant) participantMap;

    // The list of participant addresses.
    address[] participants;

    // The number of rounds in the bracket.
    uint256 numRounds;

    // The current round of the bracket, 0 indexed.
    uint256 curRound = 0;

    // The number of points awarded for each match in the current round.
    uint256 pointsPerMatch = 1;

    // A nonce used for picking winners.
    uint256 nonce = 0;

    ////////// CONSTRUCTOR //////////

    // Initializes the Base64 bracket with the given competitors.
    // The number of competitors must be a power of two between 4 and 256 inclusive.
    constructor(uint32[] memory competitorIDs, string[] memory competitorNames) Owned(msg.sender) {
        require(isPowerOfTwo(competitorIDs.length), "INVALID_BRACKET_SIZE");
        require(competitorIDs.length == competitorNames.length, "INVALID_TEAM_DATA");
        require(checkCompetitorIDs(competitorIDs), "INVALID_TEAM_IDS");

        // Initialize the competitors.
        for (uint256 i = 0; i < competitorNames.length; i++) {
            competitors[competitorIDs[i]] = Competitor(competitorIDs[i], competitorNames[i]);
        }

        // Initialize the bracket.
        uint256 competitorsLeft = competitorNames.length;

        while (competitorsLeft >= 1) {
            bracket.push();
            if (competitorsLeft > 1) {
                numRounds++;
            }

            competitorsLeft /= 2;
        }

        // Initialize the first round of the bracket.
        for (uint256 i = 0; i < competitorNames.length; i++) {
            bracket[0].push(competitorIDs[i]);
        }
    }

    ////////// PUBLIC APIS //////////

    function getBracket() external view override returns (uint256[][] memory) {
        return bracket;
    }

    function getCompetitor(uint256 competitorId) external view override returns (Competitor memory) {
        require(competitors[competitorId].id != 0, "TEAM_NOT_FOUND");

        return competitors[competitorId];
    }

    function submitEntry(uint256[][] memory entry) external payable override {
        require(msg.value >= ENTRY_FEE, "INVALID_ENTRY_FEE");
        require(entries[msg.sender].length == 0, "ALREADY_SUBMITTED");
        validateEntry(entry);

        entries[msg.sender] = entry;

        Participant memory p = Participant(msg.sender, 0, 0);

        participantMap[msg.sender] = p;
        participants.push(msg.sender);
    }

    function getEntry(address addr) external view override returns (uint256[][] memory) {
        require(entries[addr].length > 0, "ENTRY_NOT_FOUND");

        return entries[addr];
    }

    function getState() external view override returns (State) {
        return state;
    }

    function listParticipants() external view override returns (address[] memory) {
        return participants;
    }

    function getParticipant(address addr) external view override returns (Participant memory) {
        require(participantMap[addr].addr != address(0), "PARTICIPANT_NOT_FOUND");

        return participantMap[addr];
    }

    function collectPayout() external override {
        require(state == State.Finished, "TOURNAMENT_NOT_FINISHED");

        Participant memory p = participantMap[msg.sender];
        require(p.addr != address(0), "PARTICIPANT_NOT_FOUND");

        require(p.payout <= address(this).balance, "INSUFFICIENT_BALANCE");
        msg.sender.safeTransferETH(p.payout);

        p.payout = 0;
    }

    ////////// ADMIN APIS //////////

    // Advances the state of Base64.
    function advance() external onlyOwner {
        require(state != State.Finished, "TOURNAMENT_FINISHED");

        if (state == State.AcceptingEntries) {
            state = State.InProgress;
            advanceRound();
        } else if (state == State.InProgress) {
            advanceRound();
        }
    }

    ////////// PRIVATE HELPERS //////////

    // Returns true if a number is a power of 2 greater than 4 and less than 256.
    function isPowerOfTwo(uint256 x) private pure returns (bool) {
        return x >= 4 && x <= 256 && (x & (x - 1)) == 0;
    }

    // Returns true if the competitor IDs are unique and valid.
    function checkCompetitorIDs(uint32[] memory competitorIDs) private pure returns (bool) {
        for (uint256 i = 0; i < competitorIDs.length; i++) {
            for (uint256 j = i + 1; j < competitorIDs.length; j++) {
                if (competitorIDs[i] == competitorIDs[j]) {
                    return false;
                } else if (competitorIDs[i] == 0) {
                    // Competitor IDs must be greater than 0.
                    return false;
                }
            }
        }

        return true;
    }

    // Validates an entry. To save on gas, we just ensure the entry has the proper number
    // of rounds and picks, without checking the competitor IDs.
    function validateEntry(uint256[][] memory entry) private view {
        require(entry.length == numRounds, "INVALID_NUM_ROUNDS");

        uint256 numCompetitors = bracket[0].length;

        for (uint32 i = 0; i < entry.length; i++) {
            numCompetitors /= 2;

            require(entry[i].length == numCompetitors, "INVALID_NUM_TEAMS");
        }
    }

    // Advances the bracket to the next round.
    function advanceRound() private {
        require(state == State.InProgress, "TOURNAMENT_NOT_IN_PROGRESS");
        require(curRound < numRounds, "TOURNAMENT_FINISHED");

        uint256 numWinners = bracket[curRound].length / 2;

        for (uint256 i = 0; i < numWinners; i++) {
            uint256 winner = pickWinner(bracket[curRound][i * 2], bracket[curRound][(i * 2) + 1]);
            bracket[curRound + 1].push(winner);
        }

        updatePoints();

        pointsPerMatch *= 2;
        curRound++;

        if (curRound >= numRounds) {
            calculatePayouts();
            state = State.Finished;
        }
    }

    // Randomly picks a winner between two competitor IDs.
    function pickWinner(uint256 competitorID1, uint256 competitorID2) private returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 2;
        nonce++;

        if (random == 0) {
            return competitorID1;
        } else {
            return competitorID2;
        }
    }

    // Updates the participants' points according to the current bracket and the participants'
    // entries.
    function updatePoints() private {
        for (uint256 i = 0; i < participants.length; i++) {
            uint256[][] memory entry = entries[participants[i]];

            // Score the entry for the current round.
            for (uint256 j = 0; j < bracket[curRound + 1].length; j++) {
                if (bracket[curRound + 1][j] == entry[curRound][j]) {
                    participantMap[participants[i]].points += pointsPerMatch;
                }
            }
        }
    }

    // Calculates the payout for each participant.
    function calculatePayouts() private {
        uint256 totalPoints = 0;

        for (uint256 i = 0; i < participants.length; i++) {
            totalPoints += participantMap[participants[i]].points;
        }

        for (uint256 i = 0; i < participants.length; i++) {
            uint256 payout = (participantMap[participants[i]].points * address(this).balance) / totalPoints;
            participantMap[participants[i]].payout = payout;
        }
    }
}
