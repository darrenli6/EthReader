pragma solidity ^0.5.12;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable{
    
     using SafeMath for uint256;

     // 基因位数=16
     uint dnaDigits =16;

     //基因16位单位
     uint dnaModules = 10 ** dnaDigits;
     // 冷却时间1天
     uint public cooldownTime =1 days;

    // 僵尸的价格
    uint public  zombiePrice = 0.01 ether;
    
    // 初始僵尸总数
    uint public zombieCount= 0;

    struct Zombie{
      // 名字
       string  name;
       // 基因
       uint dna;
       //胜利次数
       uint16 winCount;
       //失败次数  uint16挨着写节约gas
       uint16 lossCount;
       //登记
       uint32 level;
       // 冷却时间
       uint32 readyTime;
    }

    // 僵尸数组  id=>构造体
    Zombie[] public zombies;
    //僵尸id => 拥有者
    mapping(uint=> address) public zombieToOwner;
    // 僵尸数量
    mapping(address => uint) ownerZombieCount;
    // 喂食次数
    mapping(uint => uint) public zombieFeedTimes;

    event NewZombie(uint zombieId,string name,uint dna);

    // 随机数的

    function _generateRandomDna(string memory _str) private view returns(uint){
         return uint( keccak256(abi.encodePacked(_str,now))) % dnaModules;
    }
    // internal 可以被继承
    function _createZombie(string memory _name,uint _dna) internal{
       uint id= zombies.push(Zombie(_name,_dna,0,0,1,0)) -1;
       zombieToOwner[id]=msg.sender;
       ownerZombieCount[msg.sender]=   ownerZombieCount[msg.sender].add(1);
       zombieCount=zombieCount.add(1);
       // 通知前端 创建了僵尸 
       emit NewZombie(id,_name,_dna);
    }

    // 输入名称创建僵尸
    // uint 不需要memory
    function createZombie(string memory _name) public {
        // 必须用户没有僵尸
        require(ownerZombieCount[msg.sender]==0);
      //取随机dna
        uint randDna=_generateRandomDna(_name);
       //将dna最后一位数字修改为0 
       randDna= randDna - randDna %10;
      // 返回id 返回不是序号,返回个数
      _createZombie(_name,randDna);
       
       
    } 

    //购买僵尸的
    function buyZombie(string memory _name) public payable{
        require(ownerZombieCount[msg.sender]>0);
        require(msg.value >= zombiePrice);
        uint randDna = _generateRandomDna(_name);
        randDna =randDna -randDna%10 +1;
        _createZombie(_name,randDna);

    }

    // 僵尸价格调整 
    // onlyOwner 在ownable 里  0.01 ether  = 10000000000000000
    function setZombiePrice(uint _price) external onlyOwner{
       zombiePrice = _price;
    }


}