pragma solidity >=0.7.0 <0.9.0;

contract Logic2 {

    uint public x ;

    function setX(uint _x) external {
        x=_x+1;
    }

    function getX() external view returns(uint){
        return x;
    }


}