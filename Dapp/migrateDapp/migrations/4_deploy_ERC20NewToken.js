const ERC20NewToken = artifacts.require("ERC20NewToken"); 
module.exports = function(deployer) {
    deployer.deploy(ERC20NewToken,
        "DARREN COIN","DAC",18,0);//初始发行量为0
};