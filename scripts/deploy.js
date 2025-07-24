const hre = require("hardhat");

async function main() {
  const technoLimeStore = await hre.ethers.deployContract("TechnoLimeStore");

  await technoLimeStore.waitForDeployment();

  console.log(`TechnoLimeStore deployed to ${technoLimeStore.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
