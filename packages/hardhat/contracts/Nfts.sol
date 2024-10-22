// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./LaunchpadStorage.sol";
import "./WinnerSelection.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract NFT is ERC721, LaunchStageModule, WinnerSelection{

    struct LaunchpadNftMetadata {
        uint256 numberOfWinningTickets;
    }

    uint256 private tokenCounter;
    mapping(uint256 => LaunchpadNftMetadata) private tokenIdToState;
    mapping(address => uint256) private addressToTokenId;

    event CreatedNFT(uint256 tokenId);

    constructor() ERC721("Launchpad NFT", "LNFT") {
        tokenCounter = 0;
    }

    function claimNft() public
        requireClaimPeriod 
        requireNftLaunchpadEnabled
        requireTokensClaimed 
    {
   
        uint256 tokenId = tokenCounter;
        _safeMint(msg.sender, tokenId);

        uint256 winningTicketsPerUser = getNumberOfWinningPerUser(msg.sender);

        tokenIdToState[tokenId] = LaunchpadNftMetadata(winningTicketsPerUser);

        tokenCounter ++;
        emit CreatedNFT(tokenCounter);
    }

    function getTokenCounter() public view returns (uint256) {
        return tokenCounter;
    }

    function setNftLaunchpad() public onlyOwner {
         state.flags.launchpadNfts = true;
    }

    function getNftLaunchpadInfo(address owner) public view returns (LaunchpadNftMetadata memory) {
        uint256 tokenId = addressToTokenId[owner];
        return tokenIdToState[tokenId];
    }

    modifier requireNftLaunchpadEnabled() {
        require(state.flags.launchpadNfts, "NFT launchpad is not enabled");
        _;
    }

    modifier requireTokensClaimed() {
        require(state.claimList[msg.sender], "Tokens not claimed yet");
        _;
    }
}