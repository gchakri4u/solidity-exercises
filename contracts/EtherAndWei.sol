// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract EtherAndWei {
    int256  public onewei = 1 wei;
    bool public immutable iswei;
    int public oneether = 1 ether;
    int public weis ;
    constructor() {
        iswei = onewei == 1 wei ? true:false;
    }
    function setweis(int _weis) public {
        weis = _weis;
    }
}