import { expect } from "chai";
import { ethers } from "hardhat";
import { Location } from "../typechain";

describe("Location", function () {
  const locationImageUrl = "https://imageurl.app/library.jpg";

  let location: Location;

  beforeEach(async () => {
    const Location = await ethers.getContractFactory("Location");
    location = await Location.deploy();
    await location.deployed();
  });

  it("should create a location", async function () {
    const lat = ethers.utils.parseUnits("35.481918");
    const lon = ethers.utils.parseUnits("97.508469");

    await expect(
      location.createLocation(
        lat,
        "N",
        lon,
        "W",
        "Public Library",
        "Community public library",
        locationImageUrl
      )
    )
      .to.emit(location, "LocationUpdated")
      .withArgs(0);
  });

  it("should create a user", async function () {
    await expect(location.createUser())
      .to.emit(location, "UserCreated")
      .withArgs("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  });

  it("should create a checkin event", async function () {
    const lat = ethers.utils.parseUnits("35.481918");
    const lon = ethers.utils.parseUnits("97.508469");

    await location.createLocation(
      lat,
      "N",
      lon,
      "W",
      "Public Library",
      "Community public library",
      locationImageUrl
    );

    await expect(location.checkIn(0))
      .to.emit(location, "CheckIn")
      .withArgs(0, "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  });
});
