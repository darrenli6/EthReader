[toc]

## Uniswap 

- URL :https://uniswap.org/

## github 代码

### 核心合约

- ![image.png](./img/img.png)

- UniswapV2ERC20.sol

- UniswapV2Factory.sol
  - 工厂合约部署Pair
- UniswapV2Pair.sol
  - Pair合约继承ERC20

- interfaces 
  - 接口合约，需要继承接口合约

- library 
  - 有一些工具，安全数学工具，solidity 不支持小数

### 周边合约


- ![image.png](./img/img_1.png)

- contracts 
  - UniswapV2Migrator.sol
  
  - UniswapV2Router01.sol
    
  - UniswapV2Router02.sol
  - example 
    - ExampleFlashSwap.sol 支持闪电交易，支持闪电借贷
    - ExampleOracleSimple.sol 价格预言机 区块头 区块尾 预测哪个方向发展

### v2-sdk

引用到自己的应用中，开发应用

### uniswap-lib 

库

