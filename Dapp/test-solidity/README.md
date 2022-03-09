## 给solidity智能合约编写测试脚本和高速测试的方案

>openzeppelin和mocha的测试方案不需要节点运行，测试的速度极快，如果你有很多方法要测试的时候速度快一些会很有帮助。 另外openzeppelin的测试助手和测试环境还提供了一些极为有用的小工具，例如可以模拟以太坊账户对合约的操作和时间流逝.

### 测试智能合约的流程

智能合约一旦布署就不可以修改,所以尤其要在正式布署之前做比较详细的测试.
本文就来介绍一套测试方案,通过openzeppelin提供的测试助手和mocha配合测试，和truffle提供的测试方法不一样，truffle的测试方法需要有一个节点运行。openzeppelin和mocha的测试方案不需要节点运行，测试的速度极快，如果你有很多方法要测试的时候速度快一些会很有帮助。
另外openzeppelin的测试助手和测试环境还提供了一些极为有用的小工具，例如可以模拟以太坊账户对合约的操作和时间流逝.

#### 1 首先要初始化环境

```
$ npm install truffle -g //安装过truffle就跳过
$ truffle init	//初始化truffle环境
$ npm init -y	//初始化npm环境
$ npm install @openzeppelin/contracts@2.5.0	//安装openzeppelin合约
$ npm install --save-dev @openzeppelin/test-helpers	//安装openzeppelin测试助手
$ npm install --save-dev @openzeppelin/test-environment mocha chai	//安装openzeppelin //测试环境
$ npm install @truffle/debug-utils 

```

#### 2. 修改package.json,添加测试脚本,使用mocha测试

```
vim package.json 

// package.json

"scripts": {
  "test": "mocha --exit --recursive"
}


```

#### 新建一个ERC20合约

```
$ vim contracts/MyToken.sol

```

```
pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract MyToken is ERC20, ERC20Detailed {
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

#### 4. 编译合约


```
truffle compile 
```
#### 5.编写测试脚本

```
$ vim test/MyToken.js 

```

```
const assert = require('assert');//断言
const { contract, accounts } = require('@openzeppelin/test-environment');//测试环境
const { constants,ether,expectEvent } = require('@openzeppelin/test-helpers');//测试助手
const ERC20Contract = contract.fromArtifact("MyToken"); //这里对应合约名称
//从accounts数组中初始化几个账户身份
[owner, sender, receiver, purchaser, beneficiary] = accounts;

describe("ERC20代币测试", function () {		//一个测试用例组
    it('布署合约', async function () {
        ERC20Param = [
            "My Golden Coin",   //代币名称
            "MGC",              //代币缩写
            18,                 //精度
            '10000',              //发行总量
        ];
        ERC20Instance = await ERC20Contract.new(...ERC20Param, { from: owner });//ERC20Instance变量就是布署好的合约实例
    });
});

describe("测试ERC20合约基本信息", function () {
    it('代币名称: name()', async function () {
        assert.equal(ERC20Param[0], await ERC20Instance.name());
    });
    it('代币缩写: symbol()', async function () {
        assert.equal(ERC20Param[1], await ERC20Instance.symbol());
    });
    it('代币精度: decimals()', async function () {
        assert.equal(ERC20Param[2], (await ERC20Instance.decimals()).toString());
    });
    it('代币总量: totalSupply()', async function () {
        assert.equal(ether(ERC20Param[3]).toString(), (await ERC20Instance.totalSupply()).toString());
    });
    it('创建者账户余额: balanceOf()', async function () {
        assert.equal(ether(ERC20Param[3]).toString(), (await ERC20Instance.balanceOf(owner)).toString());
    });
    it('代币发送: transfer()', async function () {
        let receipt = await ERC20Instance.transfer(receiver, ether('100'), { from: owner });
        expectEvent(receipt, 'Transfer', {
            from: owner,
            to: receiver,
            value: ether('100'),
        });
    });
    it('验证代币发送0地址错误: transfer()', async function () {
        await assert.rejects(
            ERC20Instance.transfer(
                constants.ZERO_ADDRESS,
                ether('100'),
                { from: owner }
            ),
            /ERC20: transfer to the zero address/
        );
    });
});

```

#### 6 运行测试 
```
npm run test
```

运行效果

```
darren@darrendeMacBook-Pro test-solidity % npm run test

> test-solidity@1.0.0 test
> mocha --exit --recursive



  ERC20 coin test
    ✔ 部署合约 (75ms)

  test ERC20 contract basic information
    ✔ coin name: name()
    ✔ 代币缩写: symbol()
    ✔ 代币精度: decimals()
    ✔ 代币总量: totalSupply()
    ✔ 创建者账户余额: balanceOf()
    ✔ 代币发送: transfer()
    ✔ 验证代币发送0地址错误: transfer()


  8 passing (204ms)

```

### 使用openzeppelin的测试工具和测试环境变量

####  1. 引用测试工具

```
const assert = require('assert');//断言
const { contract, accounts } = require('@openzeppelin/test-environment');//测试环境
const { constants,ether,expectEvent } = require('@openzeppelin/test-helpers');//测试助手

```

#### 2. 引用要测试和合约


```
const ERC20Contract = contract.fromArtifact("MyToken"); //这里对应合约名称

```

#### 3. 编写测试用例

```
describe("测试用例组", function () {		
    it('一个测试用例', async function () {
	//测试代码...
    });
});


```

#### 4. 断言
```
assert.equal('条件A','条件B');//断言条件A===条件B
assert.ok(bool true);//断言条件为true
await assert.rejects(async function(),/报错信息/);//断言一个异常，并且和报错信息一致（可选）

```

#### 5 测试工具


**expectEvent**一个封装好的判断事件触发点断言，其中receipt是前一个交易的收据，要在前面赋值，第二个参数是事件名称，第三个参数是一个对象，包含事件的参数值（可选)


```
expectEvent一个封装好的判断事件触发点断言，其中receipt是前一个交易的收据，要在前面赋值，第二个参数是事件名称，第三个参数是一个对象，包含事件的参数值（可选
```

accounts账户数组，可以通过以下方法赋值给一些变量名称

```
[owner, sender, receiver, purchaser, beneficiary] = accounts;

```

constants一些常量

```
constants.ZERO_ADDRESS //0地址
constants.ZERO_BYTES32 //byte32位的0
constants.MAX_UINT256 //最大的uint256
constants.MAX_INT256 //最大的int256
constants.MIN_INT256 //最小int256

```

ether将数字格式化为wei的单位,注意：参数必须为string


```
const { accounts, web3 } = require('@openzeppelin/test-environment');//在测试环境中引用
const { ether, send } = require('@openzeppelin/test-helpers');//测试助手

[owner, receiver] = accounts;
describe("测试账户余额", function () {		
    it('记录当前余额', async function () {
	ownerBalance = await web3.eth.getBalance(owner);
    });
    it('记录当前余额', async function () {
	send.ether(owner, receiver, ether('10'))
    });
    it('验证owner当前余额', async function () {
	assert.equal(ether('90').toString(),(await web3.eth.getBalance(owner)).toString());
    });
    it('验证receiver当前余额', async function () {
	assert.equal(ether('110').toString(),(await web3.eth.getBalance(receiver)).toString());
    });
});

```


#### 6 .时间工具

```
const { time } = require('@openzeppelin/test-helpers');//在测试助手中引用

```

advanceBlock强制开采一块，增加块的高度。

````
await time.advanceBlock();
```


advanceBlockTo强制开采区块直到达到目标高度,注意这个方法会减慢速度，尽量减少使用
```
await time.advanceBlockTo(target)
```

latest返回最近开采的区块时间戳，应该加上await time.advanceBlock()以检索当前区块时间

```
await time.latest()
```

latestBlock返回最新开采的区块编号
```
await time.latestBlock()
```

increase时间流逝duration秒，并用新时间挖一个新区块

```
await time.increase(duration)
```

increaseTo与increase()类似，时间流逝到target指定的时间戳

```
await time.increaseTo(target)

```

duration将不同的实践单位转化为秒， seconds,minutes,hours,days,weeks,years

```
await time.increase(time.duration.years(2));


await time.increase(time.duration.years(2));

```