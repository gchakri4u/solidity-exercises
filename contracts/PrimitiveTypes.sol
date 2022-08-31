// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract PrimitiveTypes{
    bool public test;
    int public x;
    string public greet;
    address public contractAddress;
    constructor(){
        test = true;
        x=10;
        greet="Hello";
        contractAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    }
    function setAddress(address _address) public{
        contractAddress = _address;
    }
}