
- storage 与memory的区别
```
pragma solidity^0.6.1;

struct User {
    string name;
    uint256 age;
}

contract storage_memory_demo {
    User public adminUser;
    constructor() public {
        adminUser.name = "yekai";
        adminUser.age = 40;
    }
    function setAge1(uint256 age) external {
        // age不会被修改 ,值传递,相当于copy
        User memory user = adminUser;
        user.age = age;
    }
    function setAge2(uint256 age) external {
        // age会修改,引用传递,
        User storage user = adminUser;
        user.age = age;
    }
}
```

- storage 引用传递 


- memory 值传递