const main = async () => {
  const domainContractFactory = await hre.ethers.getContractFactory('Domains');
  const domainContract = await domainContractFactory.deploy("flappy");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);

	let txn = await domainContract.register("weeknd",  {value: hre.ethers.utils.parseEther('0.1')});
	await txn.wait();
  console.log("Minted domain weeknd.flappy");

  txn = await domainContract.setMusic("weeknd", "https://www.youtube.com/watch?v=w8eFZoOcYKc");
  await txn.wait();
  console.log("Set record for weeknd.flappy");

  const address = await domainContract.getAddress("weeknd");
  console.log("Owner of domain weeknd:", address);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();