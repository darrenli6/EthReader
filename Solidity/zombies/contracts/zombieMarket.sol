pragma solidity ^0.5.12;

import './zombieOwnership.sol';

contract ZombieMarket is ZombieOwnership{
   
     uint public tax =1 finney;

     uint public minPrice =1 finney;  // = 1000000000000000


     struct zombieSales{
         // 钱转让就有payable
         address payable seller;

         uint price ;
     }
     
     mapping ( uint =>zombieSales ) public zombieShop ;

     event SaleZomebie(uint indexed zombieId, address indexed seller);

     event BuyShopZombie(uint indexed zombieId,address indexed buyer,address indexed seller);

// 销售
     function saleMyZombie(uint _zombieId,uint _price) public onlyOwnerOf(_zombieId){
            require(_price >= minPrice +tax);
            zombieShop[_zombieId] = zombieSales(msg.sender,_price);
            emit SaleZomebie(_zombieId,msg.sender);
     }

 // 购买
   function buyShopZombie(uint _zombieId) public payable{
       zombieSales memory _zombieSales =zombieShop[_zombieId];
       require(msg.value >= _zombieSales.price);
       _transfer(_zombieSales.seller, msg.sender,_zombieId);
       // 价值转移的 内置的方法
       _zombieSales.seller.transfer(msg.value -tax);
       delete zombieShop[_zombieId];
       emit BuyShopZombie(_zombieId,msg.sender,_zombieSales.seller);

   }

   //设置税金
   function setTax(uint _value) public onlyOwner{
       tax =_value ;
   }

   function SetMinPrice(uint _value) public onlyOwner{
       minPrice =_value ;
   }

}