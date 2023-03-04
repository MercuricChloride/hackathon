import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

/**
 * Deploys a contract named "YourContract" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network goerli`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const vrf = await deploy("VRF", {
    from: deployer,
    // Contract constructor arguments
    //args: [deployer],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  const _registry = await deploy("Registry", {
    from: deployer,
    log: true,
    autoMine: true,
  });

  await deploy("Gear", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["GEAR", "GEAR", _registry.address, vrf.address],
  });

  const wizard = await deploy("Wizard", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["Wizard", "Wiz", _registry.address, vrf.address],
  });

  const barbarian = await deploy("Barbarian", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["Barbarian", "Barb", _registry.address, vrf.address],
  });

  const registry = await hre.ethers.getContract("Registry", deployer);
  const gear = await hre.ethers.getContract("Gear", deployer);
  await registry.addContract(wizard.address, 2);
  await registry.addContract(barbarian.address, 2);
  await registry.setGearContract(gear.address);

  const simpleModifer = {
    stat: 1,
    mod: 10,
  };

  const anotherModifier = {
    stat: 2,
    mod: 5,
  };

  await gear.createGearData([simpleModifer, anotherModifier], 1);

  const lootBox = {
    id: 1,
    rangeStart: 1,
    rangeEnd: 1,
  };

  await gear.createLootBox([lootBox], 2);

  //allow the loot box in the registry
  await registry.addLootBox(0);

  // Get the deployed contract
  // const yourContract = await hre.ethers.getContract("YourContract", deployer);
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["YourContract"];
