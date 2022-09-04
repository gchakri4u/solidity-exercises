// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Arrays {
    int256[] public arr;

    function pushElement(int256 x) public {
        arr.push(x);
    }

    function popElement() public {
        arr.pop();
    }

    function deleteElement(uint256 index) public {
        delete arr[index];
    }

    function getElement(uint256 index) public view returns (int256) {
        return arr[index];
    }

    function printArray() public view returns (int256[] memory, uint256) {
        return (arr, arr.length);
    }
}
