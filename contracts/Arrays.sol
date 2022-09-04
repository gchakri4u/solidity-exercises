// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Arrays {
    int256[] arr;

    function addElement(int256 x) public {
        arr.push(x);
    }

    function remove(uint256 index) public {
        delete arr[index];
    }

    function get(uint256 index) public view returns (int256) {
        return arr[index];
    }
}
