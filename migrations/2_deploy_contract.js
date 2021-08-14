const Pool = artifacts.require("pool");
const WAG = artifacts.require("WAGToken");

module.exports = async function (deployer, network, accounts) {
    await deployer.deploy(WAG);
    const wag = await WAG.deployed()
    console.log(wag.address, "WAG Address");
    await deployer.deploy(Pool, wag.address);

    const balanceOwner = await wag.balanceOf(accounts[0]);
    console.log(`Owner Balance ${balanceOwner}`)
    await wag.transfer(accounts[1],1000000);
    const balanceAccount1 = await wag.balanceOf(accounts[1]);
    console.log(`Account 1 Balance ${balanceAccount1}`)
};
