pragma solidity^0.6.0;

contract var_demo {
    //作家名字 
    string public authName;
    uint256 public authAge;
    int256 authSal;
    bytes32 public authHash;
    
    constructor(string memory _name, uint256 _age, int256 _sal) public {
        authName = _name;
        authAge = _age;
        authSal = _sal;
        
        //keccak256 是以太坊使用椭圆曲线算法,用来计算hash 
        // 必须经过内置函数abi.encode转码 
        // 返回byte32 
        authHash = keccak256(abi.encode(_name, _age, _sal));
    }
}