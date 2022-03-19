pragma solidity 0.6.12;


import {ILendingPoolAddressesProvider,ILendingPool,IERC20}  from './interfaces.sol';

import {SafeMath} from './Libraries.sol';

import { FlashLoanReceiverBase } from './FlashLoanReceiverBase.sol';

contract MyV2FlashLoan is FlashLoanReceiverBase{


    using SafeMath for uint256;

address public kovanUsdc = 0xe22da380ee6B445bb8273C819444DEB6E8450422;
address public kovanAave = 0xB597cd8D3217ea6477232F9217fa70837ff667Af;
address public kovanDai = 0xFf795577d9AC8bD7090Ee22b6C1703490b6512FD;
address public kovanLink = 0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789;

   
    constructor(ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) public{

    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns(bool){
   
        

        for (uint i=0;i<assets.length;i++){
             uint amountOwing = amounts[i].add(premiums[i]);
             IERC20(assets[i]).approve(address(LENDING_POOL),amountOwing);
        }
        return true;
    }


    function myFlashLoanCall() public {
      // 接受
        address receiverAddress =address(this);

        address[] memory assets = new address[](1);
        assets[0] =kovanUsdc;

        uint256[] memory amounts= new uint256[](1);
        amounts[0]=10_000_000 *10 **18;

        // 0 flashloan  1 =stable 2 variable 

        uint256[] memory modes =new uint256[](1);
        modes[0]=0;


        address onBehalfOf=address(this);
        bytes memory params = "CryptoDarren Test flashloan";

        uint referralCode=0 ;

        LENDING_POOL.flashLoan(
            receiverAddress,
            asserts,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );


    }


}