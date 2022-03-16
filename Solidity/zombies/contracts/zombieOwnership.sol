pragma solidity ^0.5.12;

import "./zombieHelper.sol";
import "./erc721.sol";
contract ZombieOwnership is ZombieHelper,ERC721{

/*

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function transfer(address _to, uint256 _tokenId) public;
  function approve(address _to, uint256 _tokenId) public;
  function takeOwnership(uint256 _tokenId) public;
*/

mapping (uint=> address) zombieApprovals;

 function balanceOf(address _owner) public view returns (uint256 _balance){
     return ownerZombieCount[_owner];
 }
 // 想让这个变成erc721合约
 function ownerOf(uint256 _tokenId) public view returns (address _owner){
     return zombieToOwner[_tokenId];
 }
  function _transfer(address _from,address _to,uint256 _tokenId) internal{
      ownerZombieCount[_to]= ownerZombieCount[_to].add(1);
      ownerZombieCount[_from]= ownerZombieCount[_from].sub(1);
      zombieToOwner[_tokenId] =_to;
      // 触发tranfer事件 
      emit Transfer(_from, _to, _tokenId);
  }
  function transfer(address _to, uint256 _tokenId) public{
      
      _transfer(msg.sender, _to, _tokenId);
  }
  function approve(address _to, uint256 _tokenId) public{
      zombieApprovals[_tokenId] =_to;
      emit Approval(msg.sender, _to, _tokenId);

  }
  function takeOwnership(uint256 _tokenId) public{
      require(zombieApprovals[_tokenId] ==msg.sender);
      address owner =ownerOf(_tokenId);
      _transfer(owner, msg.sender, _tokenId);

  }




}