import { ethers } from "hardhat";
import dotenv from "dotenv";

dotenv.config();

const address = process.env.DEPLOY_ADDRESS || "";

const lats = ["35.481918", "34.120211", "34.893281", "34.991234", "35.231553"];

const lons = ["97.508469", "96.892112", "96.992112", "97.432144", "97.558469"];

const names = [
  "Public Library",
  "Local Coffee Shop",
  "Gas Station",
  "Grocery Store",
  "High School",
];

const descriptions = [
  "Community public library",
  "Best coffee for sale",
  "Cheap gas",
  "Town grocery",
  "Kid's school",
];

const imageUrls = [
  "https://i.imgur.com/6mA3rOd.jpeg",
  "https://i.imgur.com/ss0jYqm.jpeg",
  "https://bit.ly/333xfMX",
  "https://bit.ly/3eQsBom",
  "https://bit.ly/3nhD4Or",
];

async function main() {
  const locContract = await ethers.getContractAt("Location", address);

  for (let i = 0; i < lats.length; i++) {
    await locContract.createLocation(
      ethers.utils.parseUnits(lats[i]),
      "N",
      ethers.utils.parseUnits(lons[i]),
      "W",
      names[i],
      descriptions[i],
      imageUrls[i]
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
