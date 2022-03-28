pragma solidity >=0.7.0 <0.9.0;

interface ILogic {
 
    function setX(uint _x) external ;
    function getX() external view returns(uint);

}

contract Proxy{
   ILogic iLogic;

   function setLoginAddr(address addr) external{
       iLogic = ILogic(addr);
   } 

   function getLoginAddr() external view returns(address){ 
       return address(iLogic);
   }

   function setX(uint _x) external {
       iLogic.setX(_x);
   }

   function getX() external view returns(uint){
       return iLogic.getX();
   }

}