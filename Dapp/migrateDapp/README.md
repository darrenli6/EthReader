## 详解如何把ERC20代币迁移到新合约（升级）

> 当我们发行了ERC20代币之后,因为某些特殊原因不得不放弃掉ERC20的智能合约,而改用新合约的时候,可以通过布署一个迁移合约的方法实现将旧合约的所有代币迁移到新合约的需求.


###  创建运行环境

#### 1. 首先要初始化环境
```
$ npm init -y	//初始化npm环境
$ npm install truffle -g //安装truffle过就请跳过
$ truffle init	//初始化truffle环境
$ npm install @openzeppelin/contracts@2.5.0	//安装openzeppelin合约
$ npm install --save-dev @openzeppelin/test-helpers	//安装openzeppelin测试助手
$ npm install --save-dev @openzeppelin/test-environment mocha chai	//安装openzeppelin //测试环境
$ npm install @truffle/debug-utils 

````

#### 2. 修改package.json
```
$ vim package.json
// package.json

"scripts": {
  "test": "mocha --exit --recursive",
  "compile": "truffle compile",
  "ganache": "ganache-cli -e 1000",
  "migrate":"truffle migrate"
}


 

````


### 布署一个ERC20合约作为旧合约
#### 1. 新建一个ERC20合约

```
$ vim contracts/ERC20LegacyToken.sol
```
合约内容:

```
pragma solidity >=0.4.21 <0.7.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract ERC20LegacyToken is ERC20, ERC20Detailed {
    constructor(
        string memory name,   //代币名称
        string memory symbol, //代币缩写
        uint8 decimals,       //精度
        uint256 totalSupply   //发行总量
    ) public ERC20Detailed(name, symbol, decimals) {
        _mint(msg.sender, totalSupply * (10**uint256(decimals)));
    }
}

```
#### 2. 编译合约
```
$ npm run compile
```

#### 3.布署脚本
```
$ vim migrations/2_deploy_ERC20LegacyToken.js
const ERC20LegacyToken = artifacts.require("ERC20LegacyToken"); 
module.exports = function(deployer) {
    deployer.deploy(ERC20LegacyToken,
    "My Golden Coin","MGC",18,1000000000);
};
```
#### 4. 布署合约

```
$ npm run ganache //创建一个测试节点
$ npm run migrate //在另一个窗口运行
```



### 创建并布署迁移合约
#### 1. 创建迁移合约
```
$ vim contracts/ERC20Migrator.sol
pragma solidity ^0.5.0;
import "@openzeppelin/contracts/drafts/ERC20Migrator.sol";

//代币迁移合约
contract ERC20MigratorContract is ERC20Migrator {
    constructor(
        IERC20 legacyToken    //旧代币合约
    )
        ERC20Migrator(legacyToken)
        public
    {

    }
}
```
#### 2. 编译合约

```
$ npm run compile

```
#### 3. 布署脚本

```
$ vim migrations/3_deploy_ERC20Migrator.js
const ERC20MigratorContract = artifacts.require("ERC20MigratorContract"); 
const ERC20LegacyToken = artifacts.require("ERC20LegacyToken"); 
module.exports = async function(deployer) {
    const ERC20LegacyTokenInstance = await ERC20LegacyToken.deployed();
    deployer.deploy(
	ERC20MigratorContract,
    	ERC20LegacyTokenInstance.address
    );
};

```
#### 4. 布署合约

```
$ npm run migrate //请确保ganache测试节点还在运行

```

### 布署新的ERC20合约
#### 1. 新建一个可增发的ERC20合约

```
$ vim contracts/ERC20NewToken.sol
```

合约内容:
```
pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";

contract ERC20NewToken is ERC20, ERC20Detailed, ERC20Mintable {
    constructor(
        string memory name, //代币名称
        string memory symbol, //代币缩写
        uint8 decimals, //精度
        uint256 totalSupply //发行总量
    ) public ERC20Detailed(name, symbol, decimals) {
        _mint(msg.sender, totalSupply * (10**uint256(decimals)));
    }
}
```
#### 2. 编译合约
```
$ npm run compile
```

#### 3.布署脚本

```
$ vim migrations/4_deploy_ERC20NewToken.js


const ERC20NewToken = artifacts.require("ERC20NewToken"); 
module.exports = function(deployer) {
    deployer.deploy(ERC20NewToken,
    "My Golden Coin","MGC",18,0);//初始发行量为0
};
```

#### 4. 布署合约
```
$ npm run migrate //请确保ganache测试节点还在运行
```

 
### 通过测试脚本来模拟运行
#### 1.创建测试脚本
```
$ vim test/ERC20Migrator.js

```

```
const assert = require('assert');
const { contract, accounts, web3 } = require('@openzeppelin/test-environment');
const { ether, time, expectEvent } = require('@openzeppelin/test-helpers');
const ERC20LegacyToken = contract.fromArtifact("ERC20LegacyToken");
const ERC20Migrator = contract.fromArtifact("ERC20MigratorContract");
const ERC20NewToken = contract.fromArtifact("ERC20NewToken");

const totalSupply = '1000000000';//发行总量
[owner, sender, receiver, purchaser, beneficiary] = accounts;
EthValue = '100';
let balanceBefore = [];

//批准和迁移方法
migrateBalance = async (account) => {
    await ERC20Instance.approve(ERC20MigratorInstance.address, balanceBefore[account], { from: account });
    await ERC20MigratorInstance.migrate(account, balanceBefore[account]);
}
//验证余额方法
assertBalanceAfter = async (account) => {
    let balanceAfter = await ERC20NewTokenInstance.balanceOf(account);
    assert.equal(balanceBefore[account].toString(), balanceAfter.toString());
}
//传送方法
transfer = async (sender, receiver, amount) => {
    let receipt = await ERC20Instance.transfer(receiver, ether(amount), { from: sender });
    expectEvent(receipt, 'Transfer', {
        from: sender,
        to: receiver,
        value: ether(amount),
    });
}

describe("布署合约", function () {
    it('布署旧代币合约', async function () {
        ERC20Param = [
            "My Golden Coin",   //代币名称
            "MGC",              //代币缩写
            18,                 //精度
            totalSupply         //发行总量
        ];
        ERC20Instance = await ERC20LegacyToken.new(...ERC20Param, { from: owner });
    });
    it('布署代币迁移合约', async function () {
        ERC20MigratorInstance = await ERC20Migrator.new(
            ERC20Instance.address,        //旧代币合约地址
            { from: owner });
    });
    it('布署新代币合约', async function () {
        ERC20NewTokenParam = [
            "My Golden Coin",   //代币名称
            "MGC",              //代币缩写
            18,                 //精度
            0                   //发行总量
        ];
        ERC20NewTokenInstance = await ERC20NewToken.new(...ERC20NewTokenParam, { from: owner });
    });
});
describe("布署后首先执行", function () {
    it('将代币批准给众筹合约', async function () {
        await ERC20Instance.approve(ERC20MigratorInstance.address, ether(totalSupply.toString()), { from: owner });
    });
    it('添加众筹合约的铸造权: addMinter()', async function () {
        await ERC20NewTokenInstance.addMinter(ERC20MigratorInstance.address, { from: owner });
    });
    it('撤销发送者的铸造权: renounceMinter()', async function () {
        let receipt = await ERC20NewTokenInstance.renounceMinter({ from: owner });
        expectEvent(receipt, 'MinterRemoved', {
            account: owner
        });
    });
});
describe("迁移合约基本信息", function () {
    it('旧合约地址: legacyToken()', async function () {
        assert.equal(ERC20Instance.address, await ERC20MigratorInstance.legacyToken());
    });
});
describe("将旧合约代币分配给一些账户", function () {
    it('代币分配: transfer()', async function () {
        //代币发送给sender
        await transfer(owner, sender, (EthValue * 5).toString());
        //代币发送给receiver
        await transfer(owner, receiver, (EthValue * 10).toString());
        //代币发送给purchaser
        await transfer(owner, purchaser, (EthValue * 15).toString());
        //代币发送给beneficiary
        await transfer(owner, beneficiary, (EthValue * 25).toString());
    });
    it('记录账户旧合约余额: balanceOf()', async function () {
        balanceBefore[owner] = await ERC20Instance.balanceOf(owner);
        balanceBefore[sender] = await ERC20Instance.balanceOf(sender);
        balanceBefore[receiver] = await ERC20Instance.balanceOf(receiver);
        balanceBefore[purchaser] = await ERC20Instance.balanceOf(purchaser);
        balanceBefore[beneficiary] = await ERC20Instance.balanceOf(beneficiary);
    });
});
describe("开始迁移", function () {
    it('开始迁移: beginMigration()', async function () {
        await ERC20MigratorInstance.beginMigration(ERC20NewTokenInstance.address, { from: owner });
    });
    it('验证新约地址: newToken()', async function () {
        assert.equal(ERC20NewTokenInstance.address, await ERC20MigratorInstance.newToken());
    });
    it('迁移owner账户全部余额方法: migrateAll()', async function () {
        await ERC20MigratorInstance.migrateAll(owner);
    });
    it('迁移指定账户余额方法: migrate()', async function () {
        await migrateBalance(sender);
        await migrateBalance(receiver);
        await migrateBalance(purchaser);
        await migrateBalance(beneficiary);
    });
});
describe("验证余额", function () {
    it('验证账户迁移后新合约余额: balanceOf()', async function () {
        await assertBalanceAfter(owner);
        await assertBalanceAfter(sender);
        await assertBalanceAfter(receiver);
        await assertBalanceAfter(purchaser);
        await assertBalanceAfter(beneficiary);
    });
    it('验证账旧ERC20合约余额: balanceOf()', async function () {
        assert.equal('0', (await ERC20Instance.balanceOf(owner)).toString());
        assert.equal('0', (await ERC20Instance.balanceOf(sender)).toString());
        assert.equal('0', (await ERC20Instance.balanceOf(receiver)).toString());
        assert.equal('0', (await ERC20Instance.balanceOf(owner)).toString());
        assert.equal('0', (await ERC20Instance.balanceOf(beneficiary)).toString());
    });
});

```

#### 2. 运行测试
```
$ npm run test
```
#### 3. 运行结果

```
> truffle@1.0.0 test /home/Documents/truffle
> mocha --exit --recursive



  布署合约
    ✓ 布署旧代币合约 (404ms)
    ✓ 布署代币迁移合约 (47ms)
    ✓ 布署新代币合约 (91ms)

  布署后首先执行
    ✓ 将代币批准给众筹合约 (47ms)
    ✓ 添加众筹合约的铸造权: addMinter()
    ✓ 撤销发送者的铸造权: renounceMinter()

  迁移合约基本信息
    ✓ 旧合约地址: legacyToken()

  将旧合约代币分配给一些账户
    ✓ 代币分配: transfer() (134ms)
    ✓ 记录账户旧合约余额: balanceOf() (92ms)

  开始迁移
    ✓ 开始迁移: beginMigration()
    ✓ 验证新约地址: newToken()
    ✓ 迁移owner账户全部余额方法: migrateAll() (64ms)
    ✓ 迁移指定账户余额方法: migrate() (314ms)

  验证余额
    ✓ 验证账户迁移后新合约余额: balanceOf() (86ms)
    ✓ 验证账旧ERC20合约余额: balanceOf() (82ms)


  15 passing (2s)


```

> 在上面这个测试中,我们模拟了一个从旧ERC20代币合约迁移到新合约的全过程.
创建者首先转移了一些数量的代币给了几个用户.随后运行可迁移合约,开始迁移时指定了新合约的地址.当迁移合约布署好之后,持有旧合约代币的用户将余额批准给了迁移合约,然后从迁移合约中运行迁移方法.迁移合约先将旧合约中的批准的代币都转移到自己的账户上.然后再触发新合约中的铸币方法,在新合约中为迁移到用户生成了新的代币.