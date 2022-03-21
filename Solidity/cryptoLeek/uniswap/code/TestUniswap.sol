pragma solidity ^0.8;

import './interfaces/Uniswap.sol';
import './interfaces/IERC20.sol';


contract TestUniswap{

      address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;

      address private constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

      address private constant UNI=0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;

//USDC= 0x4DBCdF9B62e891a7cec5A2568C3F4FAF9E8Abe2b

      function swap(  address _tokenIn, 
      address _tokenOut,
      uint _amountIn,uint _amountOutMin,address _to) external{

// 发送合约之前要给授权,将usdc合约授权给本合约 approve一下
         IERC20(_tokenIn).transferFrom(msg.sender,address(this),_amountIn);

         IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER,_amountIn);

         address [] memory path;

         if (_tokenIn == WETH || _tokenOut == WETH){
             path =new address[](2);
             path[0]= _tokenIn;
             path[1]= _tokenOut;

         }else {
              path =new address[](3);
             path[0]= _tokenIn;
             path[1]= WETH;
             path[2]= _tokenOut;
         }

         IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
             _amountIn,
             _amountOutMin,
             path,
             _to,
             block.timestamp
         );


      }


      function getAmountOutMin(address _tokenIn,address _tokenOut,uint _amountIn) external view returns(uint){
          address[] memory path;

        if (_tokenIn == WETH || _tokenOut == WETH){
             path =new address[](2);
             path[0]= _tokenIn;
             path[1]= _tokenOut;

         }else {
              path =new address[](3);
             path[0]= _tokenIn;
             path[1]= WETH;
             path[2]= _tokenOut;
         }

         uint256[] memory amountOutMins =IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn,path);
          
          return amountOutMins[path.length -1];


      }

}