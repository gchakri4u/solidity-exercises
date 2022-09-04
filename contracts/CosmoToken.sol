// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CosmoToken is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    /**
     * STATE VARIABLES
     **/
    Counters.Counter private _tokenIdCounter;
    CosmoTokenStruct[] private tokens;

    /**
     * Structure to hold the current state of the token information.
     **/
    struct CosmoTokenStruct {
        uint256 tokenId;
        string tokenUri;
        uint256 royaltyType;
        uint256 royaltyPercent;
        uint256 price;
        address owner;
        address minter;
    }

    /**
     * Constructor to create a ERC721 token
     **/
    constructor() ERC721("CosmoToken", "NCOS") {}

    /**
     * Events to log at appropriate step during the transaction
     **/
    event CosmoTokenMintStart(
        address _invoker,
        address _to,
        string _uri,
        uint256 _royaltyType,
        uint256 _royaltyPercent,
        uint256 _price
    );

    event CosmoTokenMintComplete(
        address _invoker,
        address _to,
        string _uri,
        uint256 _royaltyType,
        uint256 _royaltyPercent,
        uint256 _price,
        uint256 _tokenId
    );

    event CosmoTokenBurnStart(address _invoker, uint256 _tokenId);

    event CosmoTokenBurnComplete(address _invoker, uint256 _tokenId);

    event CosmoTokenPurchaseStart(address _invoker, uint256 _tokenId);

    event CosmoTokenPurchaseComplete(address _invoker, uint256 _tokenId);

    /**
     * Modifiers
     **/
    modifier validRoyaltyType(uint256 royaltyType) {
        require(
            (royaltyType == 1 || royaltyType == 2),
            "Invalid royalty type, only 1 and 2 supported for now "
        );
        _;
    }

    modifier validRoyaltyPercent(uint256 royaltyPercent) {
        require(
            (royaltyPercent >= 1 && royaltyPercent <= 100),
            "Invalid royalty percent, value between 0-100 is valid"
        );
        _;
    }

    /**
     * Mints a ERC721 token with all the cosmo token related information
     **/
    function safeMint(
        address to,
        string memory uri,
        uint256 royaltyType,
        uint256 royaltyPercent,
        uint256 price
    )
        public
        onlyOwner
        validRoyaltyType(royaltyType)
        validRoyaltyPercent(royaltyPercent)
    {
        emit CosmoTokenMintStart(
            msg.sender,
            to,
            uri,
            royaltyType,
            royaltyPercent,
            price
        );
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        CosmoTokenStruct memory token = CosmoTokenStruct({
            tokenId: tokenId,
            tokenUri: uri,
            royaltyType: royaltyType,
            royaltyPercent: royaltyPercent,
            price: price,
            owner: to,
            minter: to
        });
        tokens.push(token);
        emit CosmoTokenMintComplete(
            msg.sender,
            to,
            uri,
            royaltyType,
            royaltyPercent,
            price,
            tokenId
        );
    }

    /**
     * Burns token with the tokenId
     **/
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /**
     * Burns token with the tokenId
     **/
    function burn(uint256 tokenId) public virtual override(ERC721Burnable) {
        emit CosmoTokenBurnStart(msg.sender, tokenId);
        super.burn(tokenId);
        delete tokens[tokenId];
        emit CosmoTokenBurnComplete(msg.sender, tokenId);
    }

    /**
     * Gets the token URI for the given tokenId
     **/
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * Gets all the token informations.
     **/
    function getTokenUris() public view returns (CosmoTokenStruct[] memory) {
        return tokens;
    }

    /**
     * Transfers token from the token owner to the purchaser
     **/
    function buy(uint256 tokenId) public payable {
        emit CosmoTokenPurchaseStart(msg.sender, tokenId);
        super.transferFrom(ownerOf(tokenId), msg.sender, tokenId);
        CosmoTokenStruct memory token = tokens[tokenId];
        token.owner = msg.sender;
        require(
            token.price <= msg.value,
            "amount is less than the token price"
        );
        if (token.royaltyType == 1) {
            payable(token.owner).transfer(msg.value);
        } else {
            (bool successMul, uint256 royaltyAmount) = computeRoyaltyAmount(
                msg.value,
                token.royaltyPercent
            );
            if (successMul) {
                payable(token.minter).transfer(royaltyAmount);
                (bool successSub, uint256 nonRoyaltyAmount) = msg.value.trySub(
                    royaltyAmount
                );
                if (successSub) {
                    payable(token.owner).transfer(nonRoyaltyAmount);
                } else {
                    revert();
                }
            } else {
                revert();
            }
        }
        emit CosmoTokenPurchaseComplete(msg.sender, tokenId);
    }

    function computeRoyaltyAmount(uint256 _amount, uint256 _royaltyPercent)
        private
        pure
        returns (bool, uint256)
    {
        (bool successDiv, uint256 computedRoyaltyPercent) = _royaltyPercent
            .tryDiv(100);
        if (successDiv) {
            return _amount.tryMul(computedRoyaltyPercent);
        } else {
            return (false, 0);
        }
    }
}