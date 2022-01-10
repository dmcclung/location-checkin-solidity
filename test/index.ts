import { expect } from "chai";
import { ethers } from "hardhat";

describe("LocationDrop", function () {
  const imageUrl = "https://fakeimg.pl/300x200/";
  const lat = ethers.utils.parseUnits("35.481918");
  const lon = ethers.utils.parseUnits("97.508469");

  const deployContract = async function () {
    const LocationDrop = await ethers.getContractFactory("LocationDrop");
    const locationDrop = await LocationDrop.deploy(100, 100, 100);
    await locationDrop.deployed();
    return locationDrop;
  };

  it("should create a location", async function () {
    const locationDrop = await deployContract();
    await expect(
      locationDrop.createLocation(
        lat,
        "N",
        lon,
        "W",
        "Public Library",
        "Community public library",
        imageUrl
      )
    )
      .to.emit(locationDrop, "LocationUpdated")
      .withArgs(0);
  });

  it("should create a user", async function () {
    const locationDrop = await deployContract();
    await expect(locationDrop.createUser())
      .to.emit(locationDrop, "UserUpdated")
      .withArgs("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  });

  it("should mint a drop", async function () {
    const locationDrop = await deployContract();
    await locationDrop.createLocation(
      lat,
      "N",
      lon,
      "W",
      "Public Library",
      "Community public library",
      imageUrl
    );

    await locationDrop.createUser();
    await expect(locationDrop.mintDrop(0, "Thank you"))
      .to.emit(locationDrop, "DropMinted")
      .withArgs(1);
  });
});
