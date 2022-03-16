

pragma solidity ^0.5.0;

contract UniswapFactoryInterface {

    address public exchangeTemplate;

    uint256 public tokenCount;


    function createExchange(address token) external returns(address exchange);

    function getExchange(address token) external view returns(address exchange);

    function getToken(address exchange) external view returns(address token);

    function getTokenWithId(uint256 tokenId) external view returns(address token);

    function initializeFactory(address template) external; 
     
}


contract UniswapExchangeInterface{
     function tokenAddress() external view returns( address token);

     function factoryAddress() external view returns (address factory);

     function addLiquidity(uint256 min_liquidity,uint256 max_tokens,uint256 a) external;





}

contract MyDefi{

    UniswapFactoryInterface uniswapFactory;

    function setup(address uniswapFactoryAddress) external{
        uniswapFactory = UniswapFactoryInterface(uniswapFactoryAddress);
    }

    function createExchange(address token )external{
        uniswapFactory.createExchange(token);
    }

    function buy(address tokenAddress, uint tokenAdmount) external payable{
        
    }


}