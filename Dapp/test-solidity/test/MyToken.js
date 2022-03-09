const assert = require('assert');//断言
const { contract, accounts } = require('@openzeppelin/test-environment');//测试环境
const { constants,ether,expectEvent } = require('@openzeppelin/test-helpers');//测试助手
const ERC20Contract = contract.fromArtifact("MyToken"); //这里对应合约名称
//从accounts数组中初始化几个账户身份
[owner, sender, receiver, purchaser, beneficiary] = accounts;
 


describe("ERC20 coin test",function(){
    it("部署合约", async function(){
        ERC20Param = [
            "LIJIA COIN", 
            "LJC",
            18,
            '100000'
        ];
        ERC20Instance =await ERC20Contract.new(...ERC20Param,{from:owner});
    });
} );



describe("test ERC20 contract basic information",function(){
    it("coin name: name()",async function(){
        assert.equal(ERC20Param[0],await ERC20Instance.name());
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
                ether('50'),
                { from: owner }
            ),
            /ERC20: transfer to the zero address/
        );
            }); 

});
