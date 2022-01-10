// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // Users receive 500 drop points every 100 blocks
  const awardBlockHeight = 100;
  const dropPointsAward = 500;
  // Users can mint a drop for 500 points
  const mintCost = 500;

  const contractFactory = await ethers.getContractFactory("LocationDrop");
  const contract = await contractFactory.deploy(
    awardBlockHeight,
    dropPointsAward,
    mintCost
  );

  await contract.deployed();

  console.log("LocationDrop deployed to:", contract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
