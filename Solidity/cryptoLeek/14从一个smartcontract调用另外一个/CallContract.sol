// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract ContractA{
   
    uint public x ;

    uint public value ;


    function setX(uint _x) public  returns(uint ){
        x=_x;
        return x;
    }
   
   function sendXandSendEther(uint _x) payable public returns(uint,uint){
       x=_x;
       value=msg.value;
       return (x,value);
   } 

   function getBalance() public view returns(uint ){
       return address(this).balance;
   }



}

// 从另外一个调用
// contract B ==> contract A

contract ContractB{
      
      function callSetX(ContractA _contractA,uint _x) public {
          _contractA.setX(_x);
      }
      function callSetXFromAddress(address contractAAddr,uint _x) public{
          ContractA contracta= ContractA(contractAAddr);
          contracta.setX(_x);
      }
      
      function callsendXandSendEther(ContractA _contractA,uint _x) public payable{
          _contractA.sendXandSendEther{value:msg.value}(_x);
      }
         
} 
