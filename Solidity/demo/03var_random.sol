pragma solidity^0.6.0;


contract random {
    address public admin;
    bytes32 public hash;
    uint256 public nowtime;
    uint256 public random_num;
    constructor() public {
        admin = msg.sender;
        //hash值
        hash = blockhash(0);
        // 时间戳
        nowtime = block.timestamp;//now 
        random_num = uint256(keccak256(abi.encode(admin, hash, nowtime)) ) % 100;
    }
}