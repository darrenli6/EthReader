
## 合约发红包

```
pragma solidity^0.6.1;

contract redpacket_demo {
    address payable public  tuhao;
    uint256 public rcount;
    mapping(address=>bool) isStake;
    //1. fa hong bao 
    constructor(uint256 count) public payable {
        require(msg.value > 0, "msg.value must > 0");
        require(count > 0, "count must > 0");
        rcount = count;
        tuhao = msg.sender;
    }
    //2. qiang hong bao 
    function stakeMoney() public payable {
        require(!isStake[msg.sender], "msg.sender must not stake");
        require(rcount >0, "rcount must > 0");
        require(getBalance() > 0, "getBalance() must > 0");
        uint256 randnum = uint256(keccak256(abi.encode(msg.sender, tuhao,now, rcount))) % 100;
        msg.sender.transfer(randnum * getBalance() / 100);
        // solidity不支持小数 先写乘法后写除法
        rcount --;
        isStake[msg.sender] = true;
    }
    //3. tuihui
    function kill() public payable {
        selfdestruct(tuhao);
    }
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
```