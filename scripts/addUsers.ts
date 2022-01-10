import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config();

const address = process.env.DEPLOY_ADDRESS || "";

async function main() {
  console.log("Running script on contract", address);
  const accounts = await ethers.getSigners();

  for (let j = 0; j < accounts.length; j++) {
    console.log("Creating user", accounts[j].address);
    const contract = await ethers.getContractAt(
      "LocationDrop",
      address,
      accounts[j]
    );
    await contract.createUser();

    await contract.mintDrop(0, "Hello");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
