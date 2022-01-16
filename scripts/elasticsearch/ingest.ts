import { Client } from "@elastic/elasticsearch";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import { uniqBy } from "lodash";
import dotenv from "dotenv";

dotenv.config();

const client = new Client({
  cloud: {
    id: process.env.ES_CLOUD_ID || "",
  },
  auth: {
    username: process.env.ES_USERNAME || "",
    password: process.env.ES_PASSWORD || "",
  },
});

const getContract = async () => {
  const locationDrop = await ethers.getContractAt(
    "LocationDrop",
    process.env.DEPLOY_ADDRESS || ""
  );
  return locationDrop;
};

const getLocationIds = async () => {
  const locationIds = [];

  const locationDrop = await getContract();
  const filter = await locationDrop.filters.LocationUpdated();
  const logs = await locationDrop.queryFilter(filter, 9976251, "latest");
  for (let i = 0; i < logs.length; i++) {
    const locationId = logs[i].args.locationId;
    locationIds.push(locationId);
  }

  return uniqBy(locationIds, "_hex");
};

const convertToDecimalDegrees = (latLon: BigNumber, nswe: string) => {
  const decimal = ethers.utils.formatUnits(latLon);
  if (nswe === "S" || nswe === "W") {
    return "-".concat(decimal);
  }

  return decimal;
};

(async () => {
  const locationDrop = await getContract();
  const locationIds = await getLocationIds();
  const indexDocs = await Promise.all(
    locationIds.map(async (locationId) => {
      const tx = await locationDrop.getLocation(locationId);
      const indexDoc = {
        index: "locations",
        id: locationId.toString(),
        body: {
          coordinate: {
            lat: convertToDecimalDegrees(tx.lat, tx.nS),
            lon: convertToDecimalDegrees(tx.lon, tx.eW),
          },
        },
      };
      return indexDoc;
    })
  );

  console.log("Starting location ingest");

  const exists = (
    await client.indices.exists({
      index: "locations",
    })
  ).body;

  if (exists) {
    console.log("Locations index exists...deleting");
    await client.indices.delete({
      index: "locations",
    });
  }

  console.log("Creating locations index");
  await client.indices.create({
    index: "locations",
    body: {
      mappings: {
        properties: {
          coordinate: {
            type: "geo_point",
          },
        },
      },
    },
  });

  console.log("Adding test locations", indexDocs.length);
  for (let k = 0; k < indexDocs.length; k++) {
    await client.index(indexDocs[k]);
  }

  console.log("Refreshing");
  await client.indices.refresh({ index: "locations" });
  console.log("Done");
})();
