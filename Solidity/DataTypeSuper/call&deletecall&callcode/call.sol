//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint256) balance;
    address owner;

    constructor() {
        owner = msg.sender;
    }

// 提取现金
    function withdraw(uint256 amount) external {
        require(balance[msg.sender] <= amount,"Bank: withdraw too much");
        balance[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Bank: may be contract call");
    }
// 从账户转到合约里
    function run() external {
        require(msg.sender == owner);
        //address(this).balance 合约的地址  
        //addr.call{value: 1ether}(“”) 功能等价 transfer(1 ether)， 但是没有 gas 限制
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Bank: may be contract call");
    }
//receive 函数: 接收以太币时回调。
    receive() external payable {
        balance[msg.sender] += msg.value;
    }
}