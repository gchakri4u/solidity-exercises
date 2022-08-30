// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
contract CountManager{
    uint public count;
    constructor(uint _count){
        count = _count;
    }
    function getCount() public view returns(uint){
      return count;
    }
    function increment() public{
      count = count +1;
    }
    function decrement() public{
      count = count - 1;
    }
}