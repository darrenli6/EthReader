const ethers = require('ethers');
const config = require('./config.json');

// Import the json file from build to get the abi
const erc_json = require('./build/ERC20.json'); //import the json of the contract which you want to interact

// You can use any standard network name
//  - "homestead"
//  - "rinkeby"
//  - "ropsten"
//  - "kovan"
//  - "goerli"
const provider = ethers.getDefaultProvider(config['network']);

// Make a wallet instance using private key and provider
const wallet = new ethers.Wallet(config['private_key'] , provider);

const address = config["ERC20"];
const abi = erc_json.abi;

erc20 = new ethers.Contract( address , abi , wallet );

 
async function test() {

    let name = await erc20.functions.name();
    let symbol = await erc20.functions.symbol();
    console.log("coin name " +name);
    console.log("coin symbol " +symbol);

    let mycontract = await erc20.functions.transfer("0x0a79cDC4fCCf91f06bC352E750650678cbFe831b","10000000000000000000");
    console.log("coin mycontract " +mycontract);


    let getbalance = await erc20.functions.balanceOf("0x0a79cDC4fCCf91f06bC352E750650678cbFe831b");
    console.log("coin getbalance " +getbalance);



    
}


test();

 
 