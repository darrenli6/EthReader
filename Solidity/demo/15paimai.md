
### 拍卖

```
pragma solidity^0.6.1;

contract aution_demo {
    address payable public seller;
    address payable public buyer;// zui gao jia zhe 
    uint256 public highAmount;
    address public admin;
    string autionName;
    bool isFinshed;
    uint256 outTime;
    
    constructor(address payable _seller, string memory _name) public {
        autionName = _name;
        seller = _seller;
        admin = msg.sender;
        isFinshed = false;
        outTime = now + 30;
        highAmount = 0;
    }
    
    // pai mai 
    function aution(uint256 amount) public payable {
        require(amount > highAmount, "amount must > highAmount");
        require(amount == msg.value, "amount must = msg.value");
        require(!isFinshed, "must not Finshed");
        require(now <= outTime, "must not time out");
        buyer.transfer(highAmount);
        buyer = msg.sender;
        highAmount = amount;
    }
    // jie shu pai mai 
    function endAuction() public payable {
        require(msg.sender == admin, "only admin can do this");
        require(now > outTime, "time is not ok");
        require(!isFinshed, "must not Finshed");
        isFinshed = true;
        seller.transfer(highAmount * 90 / 100);
    }
    
    
}
```

- 角色分析
  - 买方
  - 卖方
  - 平台方
- 平台方
  - 创建合约
  - 结束拍卖
- 买方
  - 竞拍者 价高者得
  - 