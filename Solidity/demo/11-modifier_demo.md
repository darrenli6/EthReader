
### 自定义修饰符
```
pragma solidity^0.6.0;

contract modifier_demo {
    uint256 public count;
    address public admin;
    constructor() public {
        admin = msg.sender;
        count = 1000;
    }
    modifier onlyadmin() {
        require(msg.sender == admin, "only admin can do!");
        _;
    }
    function setCount() external  onlyadmin {
        
        count *= 2;
    }
    // fallback()  external payable {
        
    // }
    // receive() external payable {
        
    // }
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract transfer_demo {
    function transfer(address payable to) external payable {
        to.transfer(msg.value);
    }
}




```