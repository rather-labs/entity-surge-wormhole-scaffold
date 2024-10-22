// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract LaunchpadStorage {

    struct Flags {
        bool hasWinnerSelectionProcessStarted;
        bool wereTicketsFiltered;
        bool winnersSelected;
        bool launchpadNfts;
    }

    struct Timeline {
        uint256 confirmationPeriodStartTime;
        uint256 winnerSelectionStartTime;
        uint256 claimStartTime;
    }

    enum NumberOfWinningTicketsType {BeforeFiltering, AfterFiltering}

    struct NumberOfWinningTickets {
        NumberOfWinningTicketsType ticketType;
        uint256 value;
    }

    struct ConfigModule {
        Timeline timeline;
        address ticketToken;
        address launchpadToken;
        uint256 launchpadTokensPerWinningTicket;
        uint256 ticketPrice;
        NumberOfWinningTickets numberOfWinningTickets;
        bool launchpadTokensDeposited;
        uint256 claimableTicketPayment;
    }

    struct TicketBatch {
        address addr;
        uint256 nrTickets;
    }

    struct TicketRange {
        uint256 firstId;
        uint256 lastId;
        uint256 guaranteedWinners;
    }

    struct LaunchpadState {
        Flags flags;
        ConfigModule configuration;
        uint256 lastTicketId;
        uint256 totalLaunchpadTokens;
        mapping(uint256 => bool) winningTickets;
        uint256 confirmedGuaranteedTickets;
        bool ownerPaymentClaimed;
        mapping(uint256 => TicketBatch) ticketBatch;
        mapping(address => TicketRange) ticketRangeForAddress;
        mapping(address => uint256) confirmedTicketsForAddress;
        mapping(uint256 => uint256) ticketPositionForTicketId;
        mapping(address => bool) blacklist;
        uint256 totalGuaranteedWinningTickets;
        uint256 selectWinnersProgress;
        uint256 filterTicketsProgressStart;
        uint256 filterTicketsProgressEnd;
        mapping(address => bool) claimList;
        mapping(address => uint256) numberOfWinningTicketsPerUser;
        uint256[2] publicKey;
        bytes32 seed;
        uint256 proof;
    }

    LaunchpadState internal state;
}