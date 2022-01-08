import { expect } from "chai";
import { ethers } from "hardhat";

describe("Location", function () {
  const imageUrl = "https://fakeimg.pl/300x200/";
  const lat = ethers.utils.parseUnits("35.481918");
  const lon = ethers.utils.parseUnits("97.508469");

  const deployContract = async function () {
    const Location = await ethers.getContractFactory("Location");
    const location = await Location.deploy();
    await location.deployed();
    return location;
  };

  it("should create a location", async function () {
    const location = await deployContract();
    await expect(
      location.createLocation(
        lat,
        "N",
        lon,
        "W",
        "Public Library",
        "Community public library",
        imageUrl
      )
    )
      .to.emit(location, "LocationUpdated")
      .withArgs(0);
  });

  it("should create a user", async function () {
    const location = await deployContract();
    await expect(location.createUser())
      .to.emit(location, "UserCreated")
      .withArgs("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  });

  it("should create a checkin event", async function () {
    const location = await deployContract();
    await location.createLocation(
      lat,
      "N",
      lon,
      "W",
      "Public Library",
      "Community public library",
      imageUrl
    );

    await expect(location.checkIn(0))
      .to.emit(location, "CheckIn")
      .withArgs(0, "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  });
});
