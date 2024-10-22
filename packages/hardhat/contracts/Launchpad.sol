pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "./VRF.sol";


import "./LaunchpadStorage.sol";
import "./Config.sol";
import "./Tickets.sol";
import "./UserInteractions.sol";
import "./Blacklist.sol";
import "./Nfts.sol";

contract Launchpad is LaunchpadStorage, Ownable, ConfigurationModule, Tickets, UserInteractions, Blacklist, NFT {
    using SafeERC20 for IERC20;

    uint32 constant callbackGasLimit = 40000;
    uint16 constant requestConfirmations = 3;
    uint32 constant numWords = 1;

    uint256 constant FIRST_TICKET_ID = 1;
    bool constant WINNING_TICKET = true;

    event ShufflerInitialized(uint256 randomSeed);

    function initShuffler(bytes memory proof_bytes) public {
        require(state.publicKey[0] != 0 && state.publicKey[1] != 0, "Public key not set");
        uint256[4] memory proof = VRF.decodeProof(proof_bytes);
        require(VRF.verify(state.publicKey, proof, bytes(getShufflerSeed())), "Invalid proof");
        state.proof = uint256(bytes32(proof_bytes));
        emit ShufflerInitialized(state.proof);
    }

    constructor(
        bytes memory proofZero,
        bytes memory publicKeyBytes,
        address launchpadTokenId,
        uint256 launchpadTokensPerWinningTicket,
        address ticketPaymentToken,
        uint256 ticketPrice,
        uint256 nrWinningTickets,
        uint256 confirmationPeriodStartTime,
        uint256 winnerSelectionStartTime,
        uint256 claimStartTime
    ) Ownable(msg.sender) NFT() {
        require(nrWinningTickets > 0, "Number of winning tickets must be greater than zero");
        uint256[2] memory publicKey = VRF.decodePoint(publicKeyBytes);
        state.publicKey = publicKey;
        require(VRF.verify(publicKey, VRF.decodeProof(proofZero), bytes("0")), "Invalid proof");
        state.configuration = ConfigModule({
            timeline: Timeline({
            confirmationPeriodStartTime: confirmationPeriodStartTime,
            winnerSelectionStartTime: winnerSelectionStartTime,
            claimStartTime: claimStartTime
        }),
            launchpadToken: launchpadTokenId,
            launchpadTokensPerWinningTicket: launchpadTokensPerWinningTicket,
            ticketToken: ticketPaymentToken,
            ticketPrice: ticketPrice,
            numberOfWinningTickets: NumberOfWinningTickets({
            ticketType: NumberOfWinningTicketsType.BeforeFiltering,
            value: nrWinningTickets
        }),
            launchpadTokensDeposited: false,
            claimableTicketPayment: 0
        });

        state.flags = Flags({
            hasWinnerSelectionProcessStarted: false,
            wereTicketsFiltered: false,
            winnersSelected: false,
            launchpadNfts: false
        });

        state.lastTicketId = 0;

        require(
            confirmationPeriodStartTime < winnerSelectionStartTime &&
            winnerSelectionStartTime < claimStartTime &&
            confirmationPeriodStartTime > block.timestamp,
            "Invalid time periods"
        );
    }
}