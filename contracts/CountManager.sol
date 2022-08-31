// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CountManager {
    uint256 public count;
    bool public error = true;
    event setEvent(uint256 count);

    function getCount() public view returns (uint256) {
        return count;
    }

    function increment() public {
        count = count + 1;
        emit setEvent(count);
    }

    function decrement() public {
        count = count - 1;
    }
}
