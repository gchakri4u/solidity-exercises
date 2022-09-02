// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Mapping{
    mapping(uint=>address) public owners;
    function addOwners(uint tokenId,address to) public{
        owners[tokenId] = to;
    }
    function deleteTokenId(uint tokenId) public {
        delete owners[tokenId];
    }
}