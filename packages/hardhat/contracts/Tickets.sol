// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LaunchpadStorage.sol";
import "./LaunchStage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract Tickets is LaunchpadStorage, Ownable, LaunchStageModule {
    using SafeERC20 for IERC20;

    event TicketsAdded(uint256 uniqueAddressesAddedCount);
    event TicketPaymentClaimed(uint256 claimedTicketPayment, uint256 extraLaunchpadTokens);

    function addTickets(address[] memory buyers, uint256[] memory confirmableTickets, uint256[] memory guaranteedWinning)
    public onlyOwner requireBeforeWinnerSelectionPeriod
    {
        require(buyers.length == confirmableTickets.length && buyers.length == guaranteedWinning.length, "Input arrays must have the same length");

        uint256 uniqueCount = 0;
        uint256 totalWinning = state.totalGuaranteedWinningTickets;
        uint256 maxWinning = state.configuration.numberOfWinningTickets.value;

        for (uint256 i = 0; i < buyers.length; i++) {
            if (tryCreateTickets(buyers[i], confirmableTickets[i], guaranteedWinning[i])) {
                require(confirmableTickets[i] >= guaranteedWinning[i], "Can't add more guaranteed winning than confirmable tickets");
                uniqueCount++;
                totalWinning += guaranteedWinning[i];
                require(totalWinning <= maxWinning, "Attempted to add too many guaranteed winning tickets");
            }
        }

        require(uniqueCount > 0, "All input addresses have already been added to the launchpad");

        state.totalGuaranteedWinningTickets = totalWinning;

        emit TicketsAdded(uniqueCount);
    }

    function tryCreateTickets(address buyer, uint256 nrTickets, uint256 guaranteedWinners) internal returns (bool) {
        if (state.ticketRangeForAddress[buyer].lastId != 0) {
            return false;
        }

        uint256 firstTicketId = state.lastTicketId + 1;
        uint256 lastTicketId = firstTicketId + nrTickets - 1;

        state.ticketRangeForAddress[buyer] = TicketRange({
            firstId: firstTicketId,
            lastId: lastTicketId,
            guaranteedWinners: guaranteedWinners
        });

        state.ticketBatch[firstTicketId] = TicketBatch({
            addr: buyer,
            nrTickets: nrTickets
        });

        state.lastTicketId = lastTicketId;

        return true;
    }

    function claimTicketPayment() public onlyOwner requireClaimPeriod {
        require(!state.ownerPaymentClaimed, "Ticket payment + leftover launchpad token refund for owner already claimed");
        state.ownerPaymentClaimed = true;

        uint256 claimableTicketPayment = state.configuration.claimableTicketPayment;
        uint256 extraLaunchpadTokens = 0;

        if (claimableTicketPayment > 0 && state.flags.winnersSelected) {
            // Transfer ticket payment to owner
            if (state.configuration.ticketToken == address(0)) {
                (bool sent,) = owner().call{value: claimableTicketPayment}("");
                require(sent, "Failed to send native coin");
            } else {
                IERC20(state.configuration.ticketToken).transfer(owner(), claimableTicketPayment);
            }
        }

        uint256 launchpadTokensBalance = state.totalLaunchpadTokens;
        uint256 numberOfWinningTickets = state.flags.winnersSelected ?
            state.configuration.numberOfWinningTickets.value : 0;
        uint256 launchpadTokensNeeded = state.configuration.launchpadTokensPerWinningTicket * numberOfWinningTickets;

        if (launchpadTokensBalance > launchpadTokensNeeded) {
            extraLaunchpadTokens = launchpadTokensBalance - launchpadTokensNeeded;
            // Transfer extra launchpad tokens to owner
            // Assuming launchpadToken is an ERC20 token
            IERC20(state.configuration.launchpadToken).transfer(owner(), extraLaunchpadTokens);
        }

        emit TicketPaymentClaimed(claimableTicketPayment, extraLaunchpadTokens);
    }

    function getTotalNumberOfTicketsForAddress(address addr) public view returns (uint256) {
        TicketRange memory range = state.ticketRangeForAddress[addr];
        if (range.lastId == 0) return 0;
        return range.lastId - range.firstId + 1;
    }

    function getTotalNumberOfTickets() public view returns (uint256) {
        return state.lastTicketId;
    }

    function clearTicketPos(uint256 ticketPos) internal {
        delete state.ticketPositionForTicketId[ticketPos];
    }

    function getTotalConfirmedTickets() public view returns (uint256) {
        return state.lastTicketId;
    }

    function removeWinningTicket(uint256 ticketId) internal {
        delete state.winningTickets[ticketId];
    }

    function setNumberOfConfirmedTickets(address addr, uint256 tickets) internal {
        state.confirmedTicketsForAddress[addr] = tickets;
    }

    function getLastTicketId() public view returns (uint256) {
        return state.lastTicketId;
    }

    function getAddTicketsPeriodEndTime() public view returns (uint256) {
        return state.configuration.timeline.confirmationPeriodStartTime;
    }

    function getWinnerSelectionStartTime() public view returns (uint256) {
        return state.configuration.timeline.winnerSelectionStartTime;
    }

    function getClaimStartTime() public view returns (uint256) {
        return state.configuration.timeline.claimStartTime;
    }

    function numberOfWinningTicketsToUint256(NumberOfWinningTickets memory nwt) internal pure returns (uint256) {
        return nwt.value;
    }

    function clearTickets(address addr) internal {
        delete state.confirmedTicketsForAddress[addr];
    }
}