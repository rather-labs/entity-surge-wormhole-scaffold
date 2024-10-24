// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LaunchpadStorage.sol";
import "./Setup.sol";
import "./WinnerSelection.sol";
import "./Tickets.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract Blacklist is LaunchpadStorage, Ownable, SetupModule, WinnerSelection {
    using SafeERC20 for IERC20;

    event UsersBlacklisted(address[] users);
    event UsersRemovedFromBlacklist(address[] users);

    function addUsersToBlacklist(address[] memory usersList) public onlyOwner beforeWinnerSelection {

        require(usersList.length > 0, "User list cannot be empty");

        for (uint256 i = 0; i < usersList.length; i++) {
            address user = usersList[i];
            _processRefund(user);
            state.blacklist[user] = true;
        }

        emit UsersBlacklisted(usersList);
    }

    function removeUsersFromBlacklist(address[] memory usersList) public onlyOwner beforeWinnerSelection {

        require(usersList.length > 0, "User list cannot be empty");

        for (uint256 i = 0; i < usersList.length; i++) {
            address user = usersList[i];
            delete state.blacklist[user];
        }

        emit UsersRemovedFromBlacklist(usersList);
    }

    function _processRefund(address user) internal {
        uint256 confirmedTickets = getNumberOfConfirmedTickets(user);
        if (confirmedTickets > 0) {
            uint256 refundAmount = confirmedTickets * (state.configuration.ticketPrice);
            delete state.confirmedTicketsForAddress[user];
            if (state.configuration.ticketToken == address(0)) {
                (bool sent,) = user.call{value: refundAmount}("");
                require(sent, "Failed to send native coin");
            } else {
                IERC20(state.configuration.ticketToken).transfer(user, refundAmount);
            }
        }
    }
}