// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CompetitorProvider} from "./CompetitorProvider.sol";
import {IBase64} from "./IBase64.sol";
import {Owned} from "../lib/solmate/src/auth/Owned.sol";
import {ResultProvider} from "./ResultProvider.sol";
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
    State _state = State.AcceptingEntries;

    // The Competitor provider.
    CompetitorProvider _competitorProvider;

    // The match result provider.
    ResultProvider _resultProvider;

    // The current bracket.
    uint256[][] _bracket;

    // The mapping from participant address to entry.
    mapping(address => uint256[][]) _entries;

    // The mapping from participant address to participant.
    mapping(address => Participant) _participantMap;

    // The list of participant addresses.
    address[] _participants;

    // The number of rounds in the bracket.
    uint256 _numRounds;

    // The current round of the bracket, 0 indexed.
    uint256 _curRound = 0;

    // The number of points awarded for each match in the current round.
    uint256 _pointsPerMatch = 1;

    ////////// CONSTRUCTOR //////////

    // Initializes the Base64 bracket with the given competitors.
    // The number of competitors must be a power of two between 4 and 256 inclusive.
    constructor(
      address competitorProvider,
      address resultProvider
    ) Owned(msg.sender) {
        _competitorProvider = CompetitorProvider(competitorProvider);
        _resultProvider = ResultProvider(resultProvider);

        // Initialize the bracket.
        uint256[] memory competitorIDs = _competitorProvider.listCompetitorIDs();
        uint256 competitorsLeft = competitorIDs.length;

        while (competitorsLeft >= 1) {
            _bracket.push();
            if (competitorsLeft > 1) {
                _numRounds++;
            }

            competitorsLeft /= 2;
        }

        // Initialize the first round of the bracket.
        for (uint256 i = 0; i < competitorIDs.length; i++) {
            _bracket[0].push(competitorIDs[i]);
        }
    }

    ////////// PUBLIC APIS //////////

    function getBracket() external view override returns (uint256[][] memory) {
        return _bracket;
    }

    function getCompetitor(uint256 competitorId) external view override returns (Competitor memory) {
        return _competitorProvider.getCompetitor(competitorId);
    }

    function submitEntry(uint256[][] memory entry) external payable override {
        require(msg.value >= ENTRY_FEE, "INVALID_ENTRY_FEE");
        require(_entries[msg.sender].length == 0, "ALREADY_SUBMITTED");
        _validateEntry(entry);

        _entries[msg.sender] = entry;

        Participant memory p = Participant(msg.sender, 0, 0);

        _participantMap[msg.sender] = p;
        _participants.push(msg.sender);
    }

    function getEntry(address addr) external view override returns (uint256[][] memory) {
        require(_entries[addr].length > 0, "ENTRY_NOT_FOUND");

        return _entries[addr];
    }

    function getState() external view override returns (State) {
        return _state;
    }

    function listParticipants() external view override returns (address[] memory) {
        return _participants;
    }

    function getParticipant(address addr) external view override returns (Participant memory) {
        require(_participantMap[addr].addr != address(0), "PARTICIPANT_NOT_FOUND");

        return _participantMap[addr];
    }

    function collectPayout() external override {
        require(_state == State.Finished, "TOURNAMENT_NOT_FINISHED");
        require(_participantMap[msg.sender].addr != address(0), "PARTICIPANT_NOT_FOUND");
        require(_participantMap[msg.sender].payout > 0, "NO_PAYOUT");
        require(_participantMap[msg.sender].payout <= address(this).balance, "INSUFFICIENT_BALANCE");

        msg.sender.safeTransferETH(_participantMap[msg.sender].payout);

        _participantMap[msg.sender].payout = 0;
    }

    ////////// ADMIN APIS //////////

    // Advances the state of Base64.
    function advance() external onlyOwner {
        require(_state != State.Finished, "TOURNAMENT_FINISHED");

        if (_state == State.AcceptingEntries) {
            _state = State.InProgress;
            _advanceRound();
        } else if (_state == State.InProgress) {
            _advanceRound();
        }
    }

    ////////// PRIVATE HELPERS //////////


    // Validates an entry. To save on gas, we just ensure the entry has the proper number
    // of rounds and picks, without checking the competitor IDs.
    function _validateEntry(uint256[][] memory entry) private view {
        require(entry.length == _numRounds, "INVALID_NUM_ROUNDS");

        uint256 numCompetitors = _bracket[0].length;

        for (uint32 i = 0; i < entry.length; i++) {
            numCompetitors /= 2;

            require(entry[i].length == numCompetitors, "INVALID_NUM_TEAMS");
        }
    }

    // Advances the bracket to the next round.
    function _advanceRound() private {
      require(_state == State.InProgress, "TOURNAMENT_NOT_IN_PROGRESS");
      require(_curRound < _numRounds, "TOURNAMENT_FINISHED");

      uint256 numWinners = _bracket[_curRound].length / 2;

      for (uint256 i = 0; i < numWinners; i++) {
          IBase64.Result memory result = _resultProvider.getResult(
              _bracket[_curRound][i * 2], _bracket[_curRound][(i * 2) + 1]);
          _bracket[_curRound + 1].push(result.winnerId);
      }

      _updatePoints();

      _pointsPerMatch *= 2;
      _curRound++;

      if (_curRound >= _numRounds) {
          _calculatePayouts();
          _state = State.Finished;
      }
    }

    // Updates the participants' points according to the current bracket and the participants'
    // entries.
    function _updatePoints() private {
        for (uint256 i = 0; i < _participants.length; i++) {
            uint256[][] memory entry = _entries[_participants[i]];

            // Score the entry for the current round.
            for (uint256 j = 0; j < _bracket[_curRound + 1].length; j++) {
                if (_bracket[_curRound + 1][j] == entry[_curRound][j]) {
                    _participantMap[_participants[i]].points += _pointsPerMatch;
                }
            }
        }
    }

    // Calculates the payout for each participant.
    function _calculatePayouts() private {
        uint256 totalPoints = 0;

        for (uint256 i = 0; i < _participants.length; i++) {
            totalPoints += _participantMap[_participants[i]].points;
        }

        for (uint256 i = 0; i < _participants.length; i++) {
            uint256 payout = (_participantMap[_participants[i]].points * address(this).balance) / totalPoints;
            _participantMap[_participants[i]].payout = payout;
        }
    }
}
