// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LaunchpadStorage.sol";
import "./LaunchStage.sol";
import "./Tickets.sol";
import "./WinnerSelection.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract UserInteractions is LaunchpadStorage, Ownable, LaunchStageModule, Tickets, WinnerSelection {
    using SafeERC20 for IERC20;

     event TicketsConfirmed(address indexed user, uint256 ticketsConfirmed);
     event TokensClaimed(address indexed user, uint256 redeemableTickets, uint256 refundedTickets);

    function confirmTickets(uint256 nrTicketsToConfirm) payable public requireConfirmationPeriod {
        require(state.configuration.launchpadTokensDeposited, "Launchpad tokens not deposited yet");
        requireUserIsNotBlacklisted(msg.sender);

        uint256 totalTickets = getTotalNumberOfTicketsForAddress(msg.sender);
        uint256 nrConfirmed = getNumberOfConfirmedTickets(msg.sender);
        uint256 totalConfirmed = nrConfirmed + nrTicketsToConfirm;
        require(totalConfirmed <= totalTickets, "Trying to confirm too many tickets");

        uint256 ticketPrice = state.configuration.ticketPrice;
        uint256 totalPrice = ticketPrice * nrTicketsToConfirm;

        // Native token transfer
        if (state.configuration.ticketToken == address(0)) {
            require(msg.value == totalPrice, "Funds in message should match total required price");
        } else {
            IERC20(state.configuration.ticketToken).transferFrom(msg.sender, address(this), totalPrice);
        }

        setNumberOfConfirmedTickets(msg.sender, totalConfirmed);

        state.seed = keccak256(bytes.concat(state.seed, keccak256(bytes.concat(bytes32(totalConfirmed)))));

        emit TicketsConfirmed(msg.sender, nrTicketsToConfirm);
    }

    function requireUserIsNotBlacklisted(address user) internal view {
        require(!state.blacklist[user], "User is blacklisted and may not confirm tickets");
    }

    function claimLaunchpadTokens() public requireClaimPeriod {
        require(!state.claimList[msg.sender], "Already claimed");

        TicketRange memory ticketRange = getTicketRangeForAddress(msg.sender);
        uint256 nrConfirmedTickets = ticketRange.guaranteedWinners;
        uint256 nrRedeemableTickets = ticketRange.guaranteedWinners;

        state.claimList[msg.sender] = true;

        if (!state.flags.winnersSelected) {
            uint256 confirmed = getNumberOfConfirmedTickets(msg.sender);
            uint256 refundAmount = state.configuration.ticketPrice * confirmed;
            if (state.configuration.ticketToken == address(0)) {
                (bool sent,) = msg.sender.call{value: refundAmount}("");
                require(sent, "Failed to send native coin");
            } else {
                IERC20(state.configuration.ticketToken).transfer(msg.sender, refundAmount);
            }
            emit TokensClaimed(msg.sender, 0, confirmed);
        } else {
            for (uint256 ticketId = ticketRange.firstId; ticketId <= ticketRange.lastId; ticketId++) {
                nrConfirmedTickets = nrConfirmedTickets + 1;
                if (isWinningTicket(ticketId)) {
                    removeWinningTicket(ticketId);
                    nrRedeemableTickets = nrRedeemableTickets + 1;
                }
                clearTicketPos(ticketId);
            }

            state.numberOfWinningTicketsPerUser[msg.sender] = nrRedeemableTickets;
            clearTickets(msg.sender);

            uint256 nrTicketsToRefund = nrConfirmedTickets - nrRedeemableTickets;
            uint256 ticketPaymentRefundAmount = state.configuration.ticketPrice * nrTicketsToRefund;

            if (state.configuration.ticketToken == address(0)) {
                (bool sent,) = msg.sender.call{value: ticketPaymentRefundAmount}("");
                require(sent, "Failed to send native coin");
            } else {
                IERC20(state.configuration.ticketToken).transfer(msg.sender, ticketPaymentRefundAmount);
            }

            uint256 tokensPerWinningTicket = state.configuration.launchpadTokensPerWinningTicket;
            uint256 launchpadTokensAmountToSend = nrRedeemableTickets * tokensPerWinningTicket;

            if (launchpadTokensAmountToSend > 0) {
                IERC20(state.configuration.launchpadToken).transfer(msg.sender, launchpadTokensAmountToSend);
            }

            emit TokensClaimed(msg.sender, nrRedeemableTickets, nrTicketsToRefund);
        }
    }

    function hasUserClaimed(address user) public view returns (bool) {
        return state.claimList[user];
    }
}