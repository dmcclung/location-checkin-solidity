import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const testAccounts = [];
if (process.env.PRIVATE_KEY) testAccounts.push(process.env.PRIVATE_KEY);
if (process.env.PRIVATE_KEY2) testAccounts.push(process.env.PRIVATE_KEY2);
if (process.env.PRIVATE_KEY3) testAccounts.push(process.env.PRIVATE_KEY3);
if (process.env.PRIVATE_KEY4) testAccounts.push(process.env.PRIVATE_KEY4);
if (process.env.PRIVATE_KEY5) testAccounts.push(process.env.PRIVATE_KEY5);

const config: HardhatUserConfig = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: process.env.RINKEBY_URL || "",
      accounts: testAccounts,
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
