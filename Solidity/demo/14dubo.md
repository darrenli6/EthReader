
## 博彩合约

```
pragma solidity^0.6.1;

struct User {
    address payable addr;
    uint256 amount;
}

contract bocai_demo {
    User[] bigs;//xia da de 
    User[] smalls;//xia xiao de 
    address admin;
    bool isFinshed;
    uint256 outtimes;
    uint256 bigTotalAmount;
    uint256 smallTotalAmount;
    uint256 result;
    
    constructor() public {
        admin = msg.sender;
        isFinshed = false;
        outtimes = now + 60;
        bigTotalAmount = 0;
        smallTotalAmount = 0;
    }
    // xia zhu 
    function bet(bool flag) public payable {
        require(msg.value > 0, "msg.value must > 0");
        require(!isFinshed, "game must not finshed");
        require(now <= outtimes, "time not out");
        if(flag) {
            //big 
            User memory user = User(msg.sender, msg.value);
            bigs.push(user);
            bigTotalAmount += msg.value;
        } else {
            User memory user = User(msg.sender, msg.value);
            smalls.push(user); 
            smallTotalAmount += msg.value;
        }
    }
    // 开奖 
    function open() public payable {
        //1. cond 
        require(!isFinshed, "only open once");
        require(outtimes <= now, "time must ok");
        //2. ji suan da hai shi xiao 
        isFinshed = true;
        result = uint256(keccak256(abi.encode(msg.sender, now, outtimes, admin,smalls.length))) % 18;
        //3. pai jiang 
        User memory user;
        if (result < 9) {
            //small 
            for (uint256 i = 0; i < smalls.length; i ++) {
                user = smalls[i];
                uint256 amount = bigTotalAmount * user.amount / smallTotalAmount * 90 / 100 + user.amount;
                user.addr.transfer(amount);
            }
        } else {
            //big 
            for (uint256 i = 0; i < bigs.length; i ++) {
                user = bigs[i];
                //还有用户的本金
                uint256 amount =  smallTotalAmount * user.amount / bigTotalAmount * 90 / 100 + user.amount;
                user.addr.transfer(amount);
            }
        }
    }
    function getBalance() external view returns (uint256, uint256, uint256) {
        return (bigTotalAmount, smallTotalAmount, address(this).balance);
    }
    function getResult() external view returns (string memory) {
        require(isFinshed, "bet must finshed");
        if (result < 9) {
            return "small";
        } else {
            return "big";
        }
    }
    
}
```

- 角色 
  - 平台方
  - 赌徒
- 平台方动作
  - 发布合约
  - 坐等开奖
- 赌徒的动作
  - 下注
  - 开奖