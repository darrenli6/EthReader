pragma solidity ^0.5.12;

import './zombieFactory.sol';

contract ZombieHelper is ZombieFactory{

    uint levelUpFee =0.001 ether;  //  1000000000000000
   
   // _ 加载到其他函数之前
    modifier aboveLevel(uint _level,uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;
    }
   
    modifier onlyOwnerOf(uint _zombieId){
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }
    
    function setLevelUpFee(uint _fee) external onlyOwner{
        levelUpFee=_fee;
       
    }

    // 升级函数
    function levelUp(uint _zombieId) external payable{
        require(msg.value >= levelUpFee) ;
        // uint256 溢出  用户成本高
        zombies[_zombieId].level++;

       
    }


    function changeName(uint _zombieId,string calldata _newName) external aboveLevel(2,_zombieId)  onlyOwnerOf(_zombieId){
             // external 如果参数string的话 要用calldatta
              zombies[_zombieId].name=_newName;

    }


    // 获取发送者的所有僵尸
    function getZombiesByOwner(address _owner) external view returns(uint[] memory){
         // new 数组
        uint[] memory result =new uint[](ownerZombieCount[_owner]);
        uint counter=0;
        for (uint i=0;i<zombies.length;i++){
            if (zombieToOwner[i]== _owner){
                result[counter]= i;
                // 溢出成本会高
                counter++;
            }
        }
        return result;

    }
    
    function _triggerColldown(Zombie storage _zombie) internal{
        _zombie.readyTime  = uint32(now +cooldownTime) - uint32((now+cooldownTime) % 1 days);


    }

   
    
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= now);
  }
    function mutiply(uint _zombieId, uint _targetDna) internal onlyOwnerOf(_zombieId){
        Zombie storage myZombie =zombies[_zombieId];
        require(_isReady(myZombie));
        _targetDna = _targetDna % dnaModules;
        uint newDna =(myZombie.dna + _targetDna) /2;
        newDna = newDna - newDna %10 +9;
        _createZombie("NoName", newDna);
        _triggerColldown(myZombie);
    }
    




 

}