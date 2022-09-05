// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BiddingNFT is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _auctionIdCounter;
    TokenDetailsStruct[] private tokenDetails;
    AuctionDetailsStruct[] private auctionDetails;
    mapping(uint256 => uint256) private tokenToAuctions;

    // Tokenid is the index of the Array.
    struct TokenDetailsStruct {
        string tokenURI;
        uint256 minBidPrice;
    }

    struct AuctionDetailsStruct {
        uint256 auctionId;
        uint256 tokenId;
        bool isOpen;
        address highestBidder;
        uint256 highestBidderPrice;
    }

    constructor() ERC721("BiddingNFT", "BFT") {}

    event TokenMintComplete();

    //Only Owner Can Mint NFT's
    function safeMint(string memory tokenURI, uint256 minBidPrice)
        public
        onlyOwner
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        TokenDetailsStruct memory currentTokenDetails = TokenDetailsStruct({
            tokenURI: tokenURI,
            minBidPrice: minBidPrice
        });
        tokenDetails.push(currentTokenDetails);
        emit TokenMintComplete();
    }

    function createAuction(uint256 tokenId) public onlyOwner {
        uint256 auctionId = _auctionIdCounter.current();
        tokenToAuctions[tokenId] = auctionId;
        auctionDetails[auctionId] = AuctionDetailsStruct({
            auctionId: auctionId,
            tokenId: tokenId,
            isOpen: true,
            highestBidder: address(0),
            highestBidderPrice: 0
        });
    }

    function bid(
        uint256 tokenId,
        address bidder,
        uint256 bidPrice
    ) public {
        uint256 auctionId = tokenToAuctions[tokenId];
        AuctionDetailsStruct memory currentAuctionDetails = auctionDetails[
            auctionId
        ];
        //TODO: Add Time Based Bid close checks
        require(currentAuctionDetails.isOpen == true, "Auction is Closed");
        require(
            bidPrice <= currentAuctionDetails.highestBidderPrice,
            "Need to bid more than the Highest bid"
        );
        auctionDetails[auctionId].highestBidder = bidder;
        auctionDetails[auctionId].highestBidderPrice = bidPrice;
    }

    function closeAuction(uint256 tokenId) public onlyOwner {
        uint256 auctionId = tokenToAuctions[tokenId];
        require(
            auctionDetails[auctionId].isOpen == false,
            "Auction is already Closed"
        );
        auctionDetails[auctionId].isOpen = false;
    }

    function buyToken(uint256 tokenId) public payable {
        uint256 auctionId = tokenToAuctions[tokenId];
        require(
            auctionDetails[auctionId].isOpen == true,
            "Auction is still Open"
        );
        require(
            msg.sender != auctionDetails[auctionId].highestBidder,
            "You are not eligible to buy token"
        );
        require(
            msg.value != auctionDetails[auctionId].highestBidderPrice,
            "You should be sending money that equals your bid price"
        );
        super.safeTransferFrom(ownerOf(tokenId), msg.sender, tokenId);
        cleanup(tokenId);
    }

    function cleanup(uint256 tokenId) private {
        delete tokenToAuctions[tokenId];
    }

    function safeBurn(uint256 tokenId) public onlyOwner {
        super.burn(tokenId);
        delete tokenDetails[tokenId];
        delete tokenToAuctions[tokenId];
    }
}
