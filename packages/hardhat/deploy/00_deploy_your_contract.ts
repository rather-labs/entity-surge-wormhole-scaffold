import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
import { Launchpad, PeerToken } from "../typechain-types";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network sepolia`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  console.log("Deployer is ", deployer);
  const { deploy } = hre.deployments;

  const publicKey = "0x035206f5bad784ae06a16da9e0d47e762a4abfe658f74db40bdfcef72368957891";
  const proof =
    "0x022b6bd6a8b84c38f95970fc7538ff1c9fd15b7e64142d7100572acd63fa500cfd563caf79fc555cf10264310b5d043dcf1b77a424bba150290b545f3400ce99b201b8913d6ea70969e2ba48c6a1e3a240";

  const launchpadTokensPerWinningTicket = 1;
  const ticketPrice = 1;

  const nrWinningTickets = 1000;
  const confirmationPeriodStartTime = Math.round(new Date().getTime() / 1000) + 120;
  const winnerSelectionStartTime = Math.round(new Date().getTime() / 1000) + 200;
  const claimStartTime = Math.round(new Date().getTime() / 1000) + 360;

  const nttToken = await deploy("PeerToken", {
    from: deployer,
    // Contract constructor arguments
    args: ["LCH", "LCH1", deployer, deployer],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  const launchpadDeploy = await deploy("Launchpad", {
    from: deployer,
    // Contract constructor arguments
    args: [
      proof,
      publicKey,
      nttToken.address,
      launchpadTokensPerWinningTicket,
      "0x0000000000000000000000000000000000000000",
      ticketPrice,
      nrWinningTickets,
      confirmationPeriodStartTime,
      winnerSelectionStartTime,
      claimStartTime,
    ],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const launchpad = await hre.ethers.getContract<Launchpad>("Launchpad", deployer);

  const launchpadToken = await hre.ethers.getContract<PeerToken>("PeerToken", deployer);
  await launchpadToken.mint(deployer, ethers.parseUnits("4000", 18));
  await launchpadToken.approve(launchpadDeploy.address, ethers.MaxUint256);
  console.log("👋 Initial greeting:", await launchpad.getShufflerSeed());
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["Launchpad"];
