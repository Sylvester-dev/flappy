const hre = require("hardhat");

async function main() {

	const [owner, randomPerson] = await hre.ethers.getSigners();
  const domainContractFactory = await hre.ethers.getContractFactory('Domains');
	const domainContract = await domainContractFactory.deploy();
	await domainContract.deployed();
  console.log("Contract deployed to:", domainContract.address);
	console.log("Contract deployed by:", owner.address);
	
	let txn = await domainContract.register("doom");
	await txn.wait();

  const domainOwner = await domainContract.getAddress("doom");
  console.log("Owner of domain:", domainOwner);

  txn = await domainContract.connect(randomPerson).setMusic("doom","haha my domain now")
  await txn.wait();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
