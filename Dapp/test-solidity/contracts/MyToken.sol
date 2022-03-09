pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract MyToken is ERC20, ERC20Detailed{
 
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply 
    ) public ERC20Detailed(name,symbol,decimals){
        _mint(msg.sender, totalSupply * (10**uint256(decimals)));
    }



}