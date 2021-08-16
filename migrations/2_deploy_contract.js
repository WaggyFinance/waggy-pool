const Pool = artifacts.require("pool");
const WAG = artifacts.require("WAGToken");
const FEE = artifacts.require("FeeToken");
const PoolHelper = artifacts.require("PoolHelper");

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(WAG);
    await deployer.deploy(FEE);
    const wag = await WAG.deployed()
    const fee = await FEE.deployed()
    const poolHelper = await deployer.deploy(PoolHelper);
    console.log(wag.address, "WAG Address");
    const pool = await deployer.deploy(Pool, wag.address,fee.address);
    await pool.setPoolHelper(poolHelper.address);

    const balanceOwner = await wag.balanceOf(accounts[0]);
    console.log(`Owner Balance ${balanceOwner}`)
    await wag.transfer(accounts[1],1000000);
    const balanceAccount1 = await wag.balanceOf(accounts[1]);
    console.log(`Account 1 Balance ${balanceAccount1}`)
};
