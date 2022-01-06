import { expect } from "chai";
import { ethers } from "hardhat";

describe("Location", function () {
  const locationImageUrl = "https://imageurl.app/library";

  it("should create a location", async function () {
    const Location = await ethers.getContractFactory("Location");
    const location = await Location.deploy();
    await location.deployed();

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
      .to.emit(location, "LocationCreated")
      .withArgs(0);
  });
});
