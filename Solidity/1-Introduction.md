

## Solidity 开发语言 
- remix地址： https://remix.ethereum.org/
- 概念
  - 一种专门开发智能合约的高级语言，在EVM环境中
  - solidity 也是一门面向对象的语言
    - solidity ,LLL, sepernt 
- 语法特点
  - address类型： 由于以太坊底层是基于账户的，所以有一个独立的address, 主要用于定位合约，账户，代码
  - 关键字- payable : 以太坊具有支付属性，在内部框架支持支付，该关键字支持语言层面的支付行为
  - 可见性：在solidity中，拥有public,private中，另外，还支持external,internal 
  - 数据位置分类: 与传统语言不同，状态语言与内存变量。状态变量永久存在
  - 异常机制: solidity与传统语言最大不同，一旦出现异常，执行都会回滚，不会出现中间状态。有原子性的特点，主要为了合约安全。

- 安装离线版的remix https://github.com/remix-run/remix.git

- VScode https://code.visualstudio.com/docs/?dv=osx

- solidity 运行环境搭建
  - solc (solidity compile ) solidity编译器