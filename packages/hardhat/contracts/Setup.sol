// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LaunchpadStorage.sol";
import "./LaunchStage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract SetupModule is LaunchpadStorage, Ownable, LaunchStageModule {
    using SafeERC20 for IERC20;

    event LaunchpadTokensDeposited(uint256 amount, address token);
    event TicketPriceSet(uint256 amount, address token);
    event LaunchpadTokensPerWinningTicketSet(uint256 amount);
    event TicketTokenSet(address token);
    event LaunchpadTokenSet(address token);
    event ConfirmationPeriodStartTimeSet(uint256 startTime);
    event WinnerSelectionStartTimeSet(uint256 startTime);
    event ClaimStartTimeSet(uint256 startTime);

    function depositLaunchpadTokens(uint256 totalWinningTickets, bool extra) public onlyOwner beforeWinnerSelection {
        require(!state.configuration.launchpadTokensDeposited || extra, "Tokens already deposited");
        require(state.configuration.launchpadTokensDeposited || !extra, "Deposit configured amount before adding extra");

        if (!extra) {
            require(totalWinningTickets == state.configuration.numberOfWinningTickets.value, "Incorrect deposit amount");
        }

        uint256 amountPerTicket = state.configuration.launchpadTokensPerWinningTicket;
        uint256 amountNeeded = amountPerTicket * totalWinningTickets;

        IERC20 launchpadToken = IERC20(state.configuration.launchpadToken);
        uint256 balanceBefore = launchpadToken.balanceOf(address(this));
        launchpadToken.safeTransferFrom(msg.sender, address(this), amountNeeded);
        uint256 balanceAfter = launchpadToken.balanceOf(address(this));
        uint256 amountDeposited = balanceAfter - balanceBefore;

        state.totalLaunchpadTokens = state.totalLaunchpadTokens + amountDeposited;

        if (extra) {
            state.configuration.numberOfWinningTickets = addToNumberOfWinningTickets(
                state.configuration.numberOfWinningTickets,
                totalWinningTickets
            );
        }

        state.configuration.launchpadTokensDeposited = true;

        emit LaunchpadTokensDeposited(amountDeposited, address(launchpadToken));
    }

    function setTicketPrice(uint256 amount) public onlyOwner requireAddTicketsPeriod {
        require(amount > 0, "Ticket price must be higher than 0");
        state.configuration.ticketPrice = amount;
        emit TicketPriceSet(amount, state.configuration.ticketToken);
    }

    function setLaunchpadTokensPerWinningTicket(uint256 amount) public onlyOwner requireAddTicketsPeriod {
        require(amount > 0, "Launchpad tokens per winning ticket cannot be set to zero");
        state.configuration.launchpadTokensPerWinningTicket = amount;
        emit LaunchpadTokensPerWinningTicketSet(amount);
    }

    function setTicketToken(address newTicketToken) public onlyOwner requireAddTicketsPeriod {
        require(newTicketToken != address(0), "Invalid token address");
        state.configuration.ticketToken = newTicketToken;
        emit TicketTokenSet(newTicketToken);
    }

    function setLaunchpadToken(address newLaunchpadToken) public onlyOwner requireAddTicketsPeriod {
        require(newLaunchpadToken != address(0), "Invalid token address");
        state.configuration.launchpadToken = newLaunchpadToken;
        emit LaunchpadTokenSet(newLaunchpadToken);
    }

    function setConfirmationPeriodStartTime(uint256 newStartTime) public onlyOwner {
        require(newStartTime > block.timestamp, "New start time must be in the future");
        require(newStartTime < state.configuration.timeline.winnerSelectionStartTime, "Must be before winner selection");
        state.configuration.timeline.confirmationPeriodStartTime = newStartTime;
        emit ConfirmationPeriodStartTimeSet(newStartTime);
    }

    function setWinnerSelectionStartTime(uint256 newStartTime) public onlyOwner {
        require(newStartTime > block.timestamp, "New start time must be in the future");
        require(newStartTime > state.configuration.timeline.confirmationPeriodStartTime, "Must be after confirmation period");
        require(newStartTime < state.configuration.timeline.claimStartTime, "Must be before claim period");
        state.configuration.timeline.winnerSelectionStartTime = newStartTime;
        emit WinnerSelectionStartTimeSet(newStartTime);
    }

    function setClaimStartTime(uint256 newStartTime) public onlyOwner {
        require(newStartTime > block.timestamp, "New start time must be in the future");
        require(newStartTime > state.configuration.timeline.winnerSelectionStartTime, "Must be after winner selection");
        state.configuration.timeline.claimStartTime = newStartTime;
        emit ClaimStartTimeSet(newStartTime);
    }

    modifier beforeWinnerSelection() {
        require(getLaunchStage() < LaunchStage.WinnerSelection, "Winner selection has already started");
        _;
    }

    function addToNumberOfWinningTickets(NumberOfWinningTickets memory nwt, uint256 value) internal pure returns (NumberOfWinningTickets memory) {
        return NumberOfWinningTickets({
            ticketType: nwt.ticketType,
            value: nwt.value + value
        });
    }
}