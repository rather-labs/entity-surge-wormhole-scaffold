// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LaunchpadStorage.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

abstract contract ConfigurationModule is LaunchpadStorage {

    function getTimeline() public view returns (Timeline memory) {
        return state.configuration.timeline;
    }

    function getShufflerSeed() public view returns (string memory) {
        return Strings.toString(uint256(state.seed));
    }

    function wereLaunchpadTokensDeposited() public view returns (bool) {
        return state.configuration.launchpadTokensDeposited;
    }

    function getLaunchpadTokenId() public view returns (address) {
        return state.configuration.launchpadToken;
    }

    function getLaunchpadTokensPerWinningTicket() public view returns (uint256) {
        return state.configuration.launchpadTokensPerWinningTicket;
    }

    function getTicketPrice() public view returns (uint256) {
        require(state.configuration.ticketPrice != 0, "Ticket price not set");
        return state.configuration.ticketPrice;
    }

    function getNumberOfWinningTickets() public view returns (NumberOfWinningTickets memory) {
        return state.configuration.numberOfWinningTickets;
    }

    function setClaimableTicketPayment(uint256 ticketPayment) internal {
        state.configuration.claimableTicketPayment = ticketPayment;
    }

    function getClaimableTicketPayment() public view returns (uint256) {
        return state.configuration.claimableTicketPayment;
    }
}