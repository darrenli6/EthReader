pragma solidity ^0.5.12;

import "./zombieHelper.sol";

contract ZombieFeeding  is ZombieHelper{

    function feed(uint _zombieId) public onlyOwnerOf(_zombieId){
        // storage 意味着指针,修改里面的值会被修改
        Zombie storage myZombie= zombies[_zombieId];
        require(_isReady(myZombie));
        zombieFeedTimes[_zombieId] = zombieFeedTimes[_zombieId].add(1);
        _triggerColldown(myZombie);
        // 
        if (zombieFeedTimes[_zombieId] %10 == 0 ){
            uint newDna =myZombie.dna - myZombie.dna %10  + 8;
            _createZombie("zombie's son",newDna);
        }


    }
}