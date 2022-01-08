import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config();

const address = process.env.DEPLOY_ADDRESS || "";

async function main() {
  const accounts = await ethers.getSigners();

  for (let j = 0; j < accounts.length; j++) {
    console.log(accounts[j].address);
    const contract = await ethers.getContractAt(
      "Location",
      address,
      accounts[j]
    );
    await contract.createUser();

    await contract.checkIn(0);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
