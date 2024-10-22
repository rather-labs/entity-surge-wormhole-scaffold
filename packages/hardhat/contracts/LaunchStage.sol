// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LaunchpadStorage.sol";

abstract contract LaunchStageModule is LaunchpadStorage {

     enum LaunchStage {
        AddTickets,
        Confirm,
        WinnerSelection,
        Claim
    }

    function getLaunchStage() public view returns (LaunchStage) {
        uint256 currentTime = block.timestamp;
        Timeline memory timeline = state.configuration.timeline;

        // Determine the launch stage based on the current time and timeline
        if (currentTime < timeline.confirmationPeriodStartTime) {
            // Before confirmation period starts
            return LaunchStage.AddTickets;
        }

        if (currentTime < timeline.winnerSelectionStartTime) {
            // During confirmation period
            return LaunchStage.Confirm;
        }

        if (currentTime < timeline.claimStartTime) {
            // Before claim start time
            return LaunchStage.WinnerSelection;
        }

        // After claim start time
        return LaunchStage.Claim;
    }

    modifier requireAddTicketsPeriod() {
        LaunchStage currentStage = getLaunchStage();
        require(currentStage == LaunchStage.AddTickets, "Add tickets period has passed");
        _;
    }

    modifier requireConfirmationPeriod() {
        LaunchStage currentStage = getLaunchStage();
        require(currentStage == LaunchStage.Confirm, "Not in confirmation period");
        _;
    }

    modifier requireBeforeWinnerSelectionPeriod() {
        LaunchStage currentStage = getLaunchStage();
        require(currentStage < LaunchStage.WinnerSelection, "Add tickets period has passed");
        _;
    }

    modifier requireWinnerSelectionPeriod() {
        LaunchStage currentStage = getLaunchStage();
        require(currentStage == LaunchStage.WinnerSelection, "Not in winner selection period");
        _;
    }

    modifier requireClaimPeriod() {
        LaunchStage currentStage = getLaunchStage();
        require(currentStage == LaunchStage.Claim, "Not in claim period");
        require(state.flags.winnersSelected, "Winners not selected yet");
        _;
    }

    function getLaunchpadStageFlags() public view returns (Flags memory) {
        return state.flags;
    }
}