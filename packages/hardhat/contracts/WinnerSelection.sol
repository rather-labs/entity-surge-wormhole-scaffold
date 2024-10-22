// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LaunchpadStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./LaunchStage.sol";

abstract contract WinnerSelection is LaunchpadStorage, Ownable, LaunchStageModule  {

    event WinnersSelected(uint256 progress, uint256 total);
    event TicketsFiltered(uint256 progress, uint256 total);

    function selectWinners(uint256 batchSize) public onlyOwner {
        require(getLaunchStage() == LaunchStage.WinnerSelection, "Not in winner selection stage");
        require(state.flags.wereTicketsFiltered, "Must filter tickets first");
        require(!state.flags.winnersSelected, "Winners already selected");
        require(state.proof != 0, "Shuffler not initialized");

        uint256 totalWinningTickets = state.configuration.numberOfWinningTickets.value;
        uint256 shufflableWinningTickets = totalWinningTickets - (state.confirmedGuaranteedTickets);
        uint256 lastTicketPosition = state.lastTicketId;

        for (uint256 i = 0; i < batchSize && state.selectWinnersProgress < shufflableWinningTickets && state.selectWinnersProgress <= lastTicketPosition; i++){
            shuffleSingleTicket(state.selectWinnersProgress, lastTicketPosition);
            state.selectWinnersProgress = state.selectWinnersProgress + 1;
        }

        if (state.selectWinnersProgress >= shufflableWinningTickets || state.selectWinnersProgress >= lastTicketPosition) {
            state.flags.winnersSelected = true;
            uint256 claimableTicketPayment = state.configuration.ticketPrice * (totalWinningTickets);
            state.configuration.claimableTicketPayment = claimableTicketPayment;
        }

        emit WinnersSelected(state.selectWinnersProgress, shufflableWinningTickets);
    }

     function shuffleSingleTicket(uint256 currentTicketPosition, uint256 lastTicketPosition) private {
        uint256 randPos = uint256(keccak256(abi.encodePacked(state.proof, currentTicketPosition))) % (lastTicketPosition - currentTicketPosition + 1) + currentTicketPosition;

        uint256 winningTicketId = getTicketIdFromPos(randPos);
        uint256 currentTicketId = getTicketIdFromPos(currentTicketPosition);

        setTicketPosToId(randPos, currentTicketId);
        setTicketPosToId(currentTicketPosition, winningTicketId);
        setWinningTicket(winningTicketId);
    }

    function filterTickets(uint256 batchSize) public onlyOwner {
        require(getLaunchStage() == LaunchStage.WinnerSelection, "Not in winner selection stage");
        require(!state.flags.wereTicketsFiltered, "Tickets already filtered");

        if (state.filterTicketsProgressStart == 0) {
            state.filterTicketsProgressStart = 1;
        }

        uint256 maxTicketId = state.lastTicketId;
        uint256 updatedMaxTicketId = maxTicketId + 1;

        for (uint256 i = 0; i < batchSize && state.filterTicketsProgressStart <= maxTicketId; i++) {

            (address ticketOwner, uint256 ticketsInBatch) = getTicketBatchDetails(state.filterTicketsProgressStart);
        
            uint256 confirmedTicketCount = getNumberOfConfirmedTickets(ticketOwner);

            if (isUserBlacklisted(ticketOwner) || confirmedTicketCount == 0) {
                clearTicketDataForAddress(ticketOwner, state.filterTicketsProgressStart);
            } else {
                uint256 guaranteedWinners = getGuaranteedWinnersForAddress(ticketOwner);
                uint256 ticketsToKeep = calculateTicketsToKeep(guaranteedWinners, confirmedTicketCount);

                uint256 newFirstTicketId = state.filterTicketsProgressStart - (state.filterTicketsProgressEnd) - (state.confirmedGuaranteedTickets);
                uint256 newLastTicketId = newFirstTicketId + (ticketsToKeep) - 1;
                updatedMaxTicketId = newLastTicketId;

                updateTicketRangeForAddress(ticketOwner, newFirstTicketId, newLastTicketId, guaranteedWinners, confirmedTicketCount);
                state.confirmedGuaranteedTickets = state.confirmedGuaranteedTickets + (getTicketRangeForAddress(ticketOwner).guaranteedWinners);
                updateTicketBatch(newFirstTicketId, ticketOwner, ticketsToKeep);
            }

            uint256 removedTicketsInBatch = ticketsInBatch - (confirmedTicketCount);
            state.filterTicketsProgressEnd = state.filterTicketsProgressEnd + (removedTicketsInBatch);

            state.filterTicketsProgressStart = state.filterTicketsProgressStart + (ticketsInBatch);
        }

        emit TicketsFiltered(state.filterTicketsProgressStart - 1, maxTicketId);

        if (state.filterTicketsProgressStart > maxTicketId) {
            updateNumberOfWinningTickets( updatedMaxTicketId + (state.confirmedGuaranteedTickets));
            state.lastTicketId = updatedMaxTicketId;
            state.flags.wereTicketsFiltered = true;
            delete state.filterTicketsProgressStart;
            delete state.filterTicketsProgressEnd;
        }
    }

    function getTicketIdFromPos(uint256 ticketPos) public view returns (uint256) {
        return state.ticketPositionForTicketId[ticketPos] == 0 ? ticketPos : state.ticketPositionForTicketId[ticketPos];
    }

    function setTicketPosToId(uint256 ticketPos, uint256 id) internal {
        state.ticketPositionForTicketId[ticketPos] = id;
    }

    function setWinningTicket(uint256 ticketId) internal {
        state.winningTickets[ticketId] = true;
    }

    function getTicketBatchDetails(uint256 batchStartId) private view returns (address, uint256) {
        TicketBatch memory batch = state.ticketBatch[batchStartId];
        return (batch.addr, batch.nrTickets);
    }

    function getNumberOfConfirmedTickets(address addr) public view returns (uint256) {
        return state.confirmedTicketsForAddress[addr];
    }

    function isUserBlacklisted(address user) public view returns (bool) {
        return state.blacklist[user];
    }

    function clearTicketDataForAddress(address user, uint256 batchStartId) private {
        delete state.ticketRangeForAddress[user];
        delete state.ticketBatch[batchStartId];
    }

    function getGuaranteedWinnersForAddress(address user) private view returns (uint256) {
        return state.ticketRangeForAddress[user].guaranteedWinners;
    }

    function calculateTicketsToKeep(uint256 guaranteedWinners, uint256 confirmedTickets) private pure returns (uint256) {
        return guaranteedWinners >= confirmedTickets ? 0 : confirmedTickets - (guaranteedWinners);
    }

    function updateTicketRangeForAddress(
        address user,
        uint256 firstId,
        uint256 lastId,
        uint256 guaranteedWinners,
        uint256 totalConfirmedTickets
    ) private {
        state.ticketRangeForAddress[user] = TicketRange({
            firstId: firstId,
            lastId: lastId,
            guaranteedWinners: guaranteedWinners < totalConfirmedTickets ? guaranteedWinners : totalConfirmedTickets
        });
    }

    function getTicketRangeForAddress(address addr) public view returns (TicketRange memory) {
        TicketRange memory range = state.ticketRangeForAddress[addr];
        require(range.lastId != 0, "Ticket range not found");
        return range;
    }

    function getNumberOfWinningTicketsForAddress(address user) public view returns (uint256) {
        require(state.flags.winnersSelected, "Winners not selected yet");
        TicketRange memory range = getTicketRangeForAddress(user);
        uint256 winningCount = 0;
        for (uint256 ticketId = range.firstId; ticketId <= range.lastId; ticketId++) {
            if (isWinningTicket(ticketId)) {
                winningCount++;
            }
        }
        return winningCount;
    }

    function isWinningTicket(uint256 ticketId) public view returns (bool) {
        return state.winningTickets[ticketId];
    }

    function updateTicketBatch(
        uint256 batchStartId,
        address user,
        uint256 nrTickets
    ) private {
        delete state.ticketBatch[batchStartId];
        state.ticketBatch[batchStartId] = TicketBatch({
            addr: user,
            nrTickets: nrTickets
        });
    }

    function updateNumberOfWinningTickets(uint256 updatedMaxTicketId) private {
        uint256 currentWinningTicketCount = state.configuration.numberOfWinningTickets.value;

        if (currentWinningTicketCount > updatedMaxTicketId) {
            state.configuration.numberOfWinningTickets = NumberOfWinningTickets({
                ticketType: NumberOfWinningTicketsType.AfterFiltering,
                value: updatedMaxTicketId
            });
        } else {
            state.configuration.numberOfWinningTickets = NumberOfWinningTickets({
                ticketType: NumberOfWinningTicketsType.AfterFiltering,
                value: currentWinningTicketCount
            });
        }
    }

    function getWinningTicketIdsForAddress(address user) public view returns (uint256[] memory) {
        require(state.flags.winnersSelected, "Winners not selected yet");

        TicketRange memory range = state.ticketRangeForAddress[user];
        uint256[] memory winningTickets = new uint256[](range.lastId - range.firstId + 1);
        uint256 winningCount = 0;

        for (uint256 ticketId = range.firstId; ticketId <= range.lastId; ticketId++) {
            if (isWinningTicket(ticketId)) {
                winningTickets[winningCount] = ticketId;
                winningCount++;
            }
        }

        uint256[] memory filteredWinningTickets = new uint256[](winningCount);
        for (uint256 i = 0; i < winningCount; i++) {
            filteredWinningTickets[i] = winningTickets[i];
        }

        return filteredWinningTickets;
    }

    function getNumberOfWinningPerUser(address addr) public view returns (uint256) {
        // TODO: add a check to allow this function to be called only after launchpad has been claimed
        return state.numberOfWinningTicketsPerUser[addr];
    }
}