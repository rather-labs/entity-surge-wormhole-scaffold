import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { LaunchpadToken } from "../typechain-types";
import { ethers } from "hardhat";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
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

  const launchpadTokenDeploy = await deploy("LaunchpadToken", {
    from: deployer,
    // Contract constructor arguments
    args: ["LNCH", "LNCH", deployer, deployer],
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
      launchpadTokenDeploy.address,
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

  const launchpadToken = await hre.ethers.getContract<LaunchpadToken>("LaunchpadToken", deployer);
  await launchpadToken.mint(deployer, ethers.parseUnits("4000", 18));
  await launchpadToken.approve(launchpadDeploy.address, ethers.MaxUint256);
  console.log("Launchpad + Token deployed successfully!");
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["Launchpad"];
