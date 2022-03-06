pragma solidity ^0.4.16;

contract A{

    address public address1;
    address public address2;

    uint256 public numA;
    uint256 public numB;
    uint256 public numC;
    
    function callContractB(address contractBaddr) public {
       contractBaddr.delegatecall(bytes4(keccak256("run_sum(address)")),this); // this即本合约地址
    }

    function setNumA(uint256 v) public{
        numA=v;
    }
    function setNumB(uint256 v) public{
        numB=v;
    }
    function setNumC(uint256 v) public{
        numC=v;
    }

    function getNumA() public view returns( uint256){
        return numA;
    }
     function getNumB() public view returns(uint256){
        return numB;
    }
  
    

}


contract B {
    address public address1;
    address public address2;

    uint256 public numA;
    uint256 public numB;
    uint256 public numC;

    function calcSum(uint256 a,uint256 b) public returns(uint256){
        return a+b;
    }

    function run_sum(address contractAaddr) public {
        address1 =contractAaddr; // A合约地址
        address2 =msg.sender;

        A contractA;
        contractA =A(contractAaddr);
        contractA.setNumC(calcSum(contractA.getNumA(),contractA.getNumB()));
    }
}