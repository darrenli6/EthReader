pragma solidity ^0.5.12;

import "./zombieHelper.sol";


contract ZombieAttack is ZombieHelper{

    uint  randNonce= 0 ;

    uint attackVictoryProbability  = 70; 

    function randMod(uint _modules) internal returns(uint){
        randNonce ++;
        return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modules;
    }

    function setAttackVictoryProbability(uint _attackVictoryProbability) public onlyOwner{
         attackVictoryProbability=_attackVictoryProbability;
    }

    function attack(uint _zombieId,uint _targetId) external onlyOwnerOf(_zombieId){
        Zombie storage myZombie =zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];
        uint rand =randMod(100);
        if (rand <= attackVictoryProbability){
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            mutiply(_zombieId,enemyZombie.dna);
        }else{
             myZombie.lossCount++;
             enemyZombie.winCount++;
             _triggerColldown(myZombie);
        }
    }


}