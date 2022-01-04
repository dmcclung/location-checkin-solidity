import { expect } from "chai";
import { ethers } from "hardhat";

describe("Location", function () {
  const locationImageUrl =
    "https://imgr.search.brave.com/EReJfoKCP_Aij2WtwOyNqfaQ6PZsyiwRS5PKOtKTjPU/fit/1200/1200/ce/1/aHR0cHM6Ly9vaGlv/c3RhdGUucHJlc3Ni/b29rcy5wdWIvYXBw/L3VwbG9hZHMvc2l0/ZXMvMTk4LzIwMTkv/MDYvZXh0ZXJpb3Iy/LTIuanBn";

  it("should create a location", async function () {
    const Location = await ethers.getContractFactory("Location");
    const location = await Location.deploy();
    await location.deployed();

    // from wei, what about the sign, store it as a string
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
