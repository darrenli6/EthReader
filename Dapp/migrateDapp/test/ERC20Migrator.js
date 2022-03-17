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
            "DARREN COIN","DAC",   //代币名称  代币缩写                  
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
            "DARREN COIN","DAC",   //代币名称  代币缩写   
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

