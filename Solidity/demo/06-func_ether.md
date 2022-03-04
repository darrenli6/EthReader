
- 充值&体现

```
pragma solidity^0.6.0;

contract func_ether {
    // chong zhi 
    function deposit() public payable {
        //ok
    }
    //contract is a address 
    //address.balance is yu'e 
    function getBalance() public view returns (uint256) {
        // this 合约的对象
        // 合约的余额
        return address(this).balance;
    }
    // ti xian 
    function withdraw(uint256 amount) public payable {
        //msg.sender -> 
        msg.sender.transfer(amount);
    }
}


```

- 充值 
  - 函数 + payable
  - msg.value大于0 
- 提现
  - 地址 + payable
  - address.transfer(uin256 amount)