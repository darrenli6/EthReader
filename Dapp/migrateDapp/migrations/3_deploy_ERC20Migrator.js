const ERC20MigratorContract = artifacts.require("ERC20MigratorContract"); 
const ERC20LegacyToken = artifacts.require("ERC20LegacyToken"); 
module.exports = async function(deployer) {
    const ERC20LegacyTokenInstance = await ERC20LegacyToken.deployed();
    deployer.deploy(
	ERC20MigratorContract,
    	ERC20LegacyTokenInstance.address
    );
};


