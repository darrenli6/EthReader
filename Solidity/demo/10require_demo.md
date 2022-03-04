### solidity错误处理

```
pragma solidity^0.6.0;

contract require_demo {
    // chong zhi 
    function deposit(uint256 amount) public payable {
        //ok
        require(msg.value == amount, "msg.value must equal amount");
        assert(amount > 0);
    }
    
}
```

- assert 对用户惩罚,扣光gas 
  - 内部变量判断
  - 用于pure函数
  - 用于检测错误
- require 温和,退还剩余的gas
  - 业务逻辑判断