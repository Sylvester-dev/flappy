const hre = require("hardhat");

async function main() {

	const [owner, randomPerson] = await hre.ethers.getSigners();
  const domainContractFactory = await hre.ethers.getContractFactory('Domains');
	const domainContract = await domainContractFactory.deploy("flappy"); //pass flappy to constructor
	await domainContract.deployed();
  console.log("Contract deployed to:", domainContract.address);
	console.log("Contract deployed by:", owner.address);
	
	let txn = await domainContract.register("hacked",{value:hre.ethers.utils.parseEther('1234')});
	await txn.wait();

  // const domainOwner = await domainContract.getAddress("doooom");
  // console.log("Owner of domain:", domainOwner);
  
  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));

  try {
    txn = await domainContract.connect(randomPerson).withdraw(); //try'na steal some money
    await txn.wait();
  } catch(error){
    console.log("Could not rob contract");
  }

    // Owner balance in wallet
    let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("Balance of owner before withdrawal:", hre.ethers.utils.formatEther(ownerBalance));
  
    // Oops, looks like the owner is saving their money!
    txn = await domainContract.connect(owner).withdraw();
    await txn.wait();
    
    // Fetch balance of contract & owner
    const contractBalance = await hre.ethers.provider.getBalance(domainContract.address);
    ownerBalance = await hre.ethers.provider.getBalance(owner.address);
  
    console.log("Contract balance after withdrawal:", hre.ethers.utils.formatEther(contractBalance));
    console.log("Balance of owner after withdrawal:", hre.ethers.utils.formatEther(ownerBalance));

  //testing
  // txn = await domainContract.connect(randomPerson).setMusic("doom","haha my domain now")
  // await txn.wait();
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
