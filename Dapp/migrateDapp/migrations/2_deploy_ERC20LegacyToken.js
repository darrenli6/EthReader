const ERC20LegacyToken = artifacts.require("ERC20LegacyToken"); 
module.exports = function(deployer) {
    deployer.deploy(ERC20LegacyToken,
    "DARREN COIN","DAC",18,1000000000);
};
