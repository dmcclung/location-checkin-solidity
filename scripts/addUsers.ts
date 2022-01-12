import { ethers } from "hardhat";
import dotenv from "dotenv";
import { BigNumber } from "ethers";

dotenv.config();

const address = process.env.DEPLOY_ADDRESS || "";

async function main() {
  console.log("Running script on contract", address);
  const accounts = await ethers.getSigners();

  const dropIdsMinted: BigNumber[] = [];
  const contract = await ethers.getContractAt(
    "LocationDrop",
    address,
    accounts[0]
  );

  const listener = (dropId: BigNumber) => {
    dropIdsMinted.push(dropId);
  };

  contract.on("DropMinted", listener);

  for (let j = 0; j < accounts.length; j++) {
    console.log("Creating user", accounts[j].address);
    const contract = await ethers.getContractAt(
      "LocationDrop",
      address,
      accounts[j]
    );
    let tx = await contract.createUser();
    await tx.wait();

    console.log("Mint drop on locationId 0 for user", accounts[j].address);
    tx = await contract.mintDrop(0, "Hello");
    await tx.wait();
  }

  // Need to wait to catch the last mint event
  await new Promise((resolve) => setTimeout(resolve, 2000));

  if (dropIdsMinted.length !== accounts.length) {
    throw new Error("Did a drop mint fail?");
  }

  for (let i = 0; i < dropIdsMinted.length; i++) {
    const dropId = dropIdsMinted[i];
    const contract = await ethers.getContractAt(
      "LocationDrop",
      address,
      accounts[i]
    );

    const proofUri = "https://fakeimg.pl/350x200/?text=Hey";

    console.log("Uploading proof for dropId", dropId.toString());
    const tx = await contract.setProofOfBeingThere(dropId, proofUri);
    await tx.wait();
  }

  contract.off("DropMinted", listener);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
