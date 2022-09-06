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
    mapping(uint256 => TokenToAuctionsStruct) private tokenToAuctions;

    // Tokenid is the index of the Array.
    struct TokenDetailsStruct {
        string tokenURI;
        uint256 minBidPrice;
    }
    struct TokenToAuctionsStruct {
        uint256 auctionId;
        bool isExists;
    }

    struct AuctionDetailsStruct {
        uint256 auctionId;
        uint256 tokenId;
        bool isOpen;
        address highestBidder;
        uint256 highestBidderPrice;
    }

    constructor() ERC721("BiddingNFT", "BFT") {}

    event TokenMintStart(
        address _invoker,
        string _tokenURI,
        uint256 _minBidPrice
    );

    event TokenMintComplete(
        address _invoker,
        uint256 _tokenId,
        string _tokenURI,
        uint256 _minBidPrice
    );

    //Only Owner Can Mint NFT's
    function safeMint(string memory tokenURI, uint256 minBidPrice)
        public
        onlyOwner
    {
        emit TokenMintStart(msg.sender, tokenURI, minBidPrice);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        TokenDetailsStruct memory currentTokenDetails = TokenDetailsStruct({
            tokenURI: tokenURI,
            minBidPrice: minBidPrice
        });
        tokenDetails.push(currentTokenDetails);
        emit TokenMintComplete(msg.sender, tokenId, tokenURI, minBidPrice);
    }

    function openAuction(uint256 tokenId) public onlyOwner {
        require(
            tokenToAuctions[tokenId].isExists == false ||
                (tokenToAuctions[tokenId].isExists == true &&
                    auctionDetails[tokenToAuctions[tokenId].auctionId].isOpen ==
                    false),
            "Auction already exists"
        );
        uint256 auctionId = _auctionIdCounter.current();
        tokenToAuctions[tokenId] = TokenToAuctionsStruct({
            auctionId: auctionId,
            isExists: true
        });
        AuctionDetailsStruct
            memory currentAuctionDetails = AuctionDetailsStruct({
                auctionId: auctionId,
                tokenId: tokenId,
                isOpen: true,
                highestBidder: address(0),
                highestBidderPrice: 0
            });
        auctionDetails.push(currentAuctionDetails);
    }

    function bid(uint256 tokenId, uint256 bidPrice) public {
        require(ownerOf(tokenId) != msg.sender, "Owner Should not bid");
        require(
            tokenToAuctions[tokenId].isExists == true &&
                auctionDetails[tokenToAuctions[tokenId].auctionId].isOpen ==
                true,
            "Auction is Closed"
        );
        uint256 auctionId = tokenToAuctions[tokenId].auctionId;
        AuctionDetailsStruct memory currentAuctionDetails = auctionDetails[
            auctionId
        ];
        //TODO: Add Time Based Bid close checks
        require(
            bidPrice >= tokenDetails[tokenId].minBidPrice &&
                bidPrice >= currentAuctionDetails.highestBidderPrice,
            "Need to bid more than the Highest bid"
        );
        auctionDetails[auctionId].highestBidder = msg.sender;
        auctionDetails[auctionId].highestBidderPrice = bidPrice;
    }

    function closeAuction(uint256 tokenId) public onlyOwner {
        require(
            tokenToAuctions[tokenId].isExists == true &&
                auctionDetails[tokenToAuctions[tokenId].auctionId].isOpen ==
                true,
            "Auction is Closed"
        );
        uint256 auctionId = tokenToAuctions[tokenId].auctionId;
        auctionDetails[auctionId].isOpen = false;
        if (auctionDetails[auctionId].highestBidder == address(0)) {
            cleanup(tokenId);
        } else {
            super.approve(auctionDetails[auctionId].highestBidder, tokenId);
        }
    }

    function buyToken(uint256 tokenId) public payable returns (bool) {
        require(
            tokenToAuctions[tokenId].isExists == true &&
                auctionDetails[tokenToAuctions[tokenId].auctionId].isOpen ==
                false,
            "Auction is Still Open"
        );
        uint256 auctionId = tokenToAuctions[tokenId].auctionId;
        require(
            msg.sender == auctionDetails[auctionId].highestBidder,
            "You are not eligible to buy token"
        );
        require(
            msg.value >= auctionDetails[auctionId].highestBidderPrice,
            "You should be sending money atleast your bid price"
        );
        super.safeTransferFrom(ownerOf(tokenId), msg.sender, tokenId);
        (bool sent, ) = payable(ownerOf(tokenId)).call{value: msg.value}("");
        require(sent == true, "Failed to send Ether to Owner of token");
        cleanup(tokenId);
        return sent;
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
