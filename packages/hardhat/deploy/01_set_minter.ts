import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { LaunchpadToken } from "../typechain-types";
import deployments from "./deployment.json";

const setMinter: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const launchpadToken = await hre.ethers.getContract<LaunchpadToken>("LaunchpadToken", deployer);
  const network = hre.network.name[0].toUpperCase() + hre.network.name.substring(1);
  await launchpadToken.setMinter(deployments.chains[network].manager);
  console.log("SetMinter completed!");
};

export default setMinter;

setMinter.tags = ["SetMinter"];
