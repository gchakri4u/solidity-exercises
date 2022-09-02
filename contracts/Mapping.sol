// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Mapping {
    mapping(uint256 => address) public owners;

    mapping(uint256 => TokenDetailsStruct) tokenDetails;
    struct TokenDetailsStruct {
        string description;
        string tokenUri;
    }

    function getTokenDetails(uint256 tokenId)
        public
        view
        returns (string memory, string memory)
    {
        TokenDetailsStruct memory tokenDetailsRow = tokenDetails[tokenId];
        return (tokenDetailsRow.description, tokenDetailsRow.tokenUri);
    }

    function addTokenDetails(
        uint256 tokenId,
        string memory description,
        string memory tokenUri
    ) public {
        TokenDetailsStruct memory tokenDetailsRow = TokenDetailsStruct({
            description: description,
            tokenUri: tokenUri
        });
        tokenDetails[tokenId] = tokenDetailsRow;
    }

    function getOwner(uint256 tokenId) public view returns (address) {
        return owners[tokenId];
    }

    function addOwners(uint256 tokenId, address to) public {
        owners[tokenId] = to;
    }

    function deleteTokenId(uint256 tokenId) public {
        delete owners[tokenId];
    }
}
