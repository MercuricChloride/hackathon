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

  //const vrf = await deploy("VRF", {
  //  from: deployer,
  //  // Contract constructor arguments
  //  //args: [deployer],
  //  log: true,
  //  // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
  //  // automatically mining the contract deployment transaction. There is no effect on live networks.
  //  autoMine: true,
  //});

  //const _registry = await deploy("Registry", {
  //  from: deployer,
  //  log: true,
  //  autoMine: true,
  //});

  //await deploy("Gear", {
  //  from: deployer,
  //  log: true,
  //  autoMine: true,
  //  args: ["GEAR", "GEAR", _registry.address, vrf.address],
  //});

  //const wizard = await deploy("Wizard", {
  //  from: deployer,
  //  log: true,
  //  autoMine: true,
  //  args: ["Wizard", "Wiz", _registry.address, vrf.address],
  //});

  //const barbarian = await deploy("Barbarian", {
  //  from: deployer,
  //  log: true,
  //  autoMine: true,
  //  args: ["Barbarian", "Barb", _registry.address, vrf.address],
  //});

  //const gold = await deploy("Gold", {
  //  from: deployer,
  //  log: true,
  //  autoMine: true,
  //  args: [],
  //});

  //const dungeon = await deploy("Dungeon", {
  //  from: deployer,
  //  log: true,
  //  autoMine: true,
  //  args: [vrf.address, gold.address],
  //});

  const registryAdd = "0x71aC562ee21D5D1F953646Df06e62FC17752743D";
  const vrfAdd = "0x8a7Ca7205F72602f571721DbC1cbAA87830DF8AE";

  const rogue = await deploy("Rogue", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["Rogue", "Rogue", registryAdd, vrfAdd],
  });

  const paladin = await deploy("Paladin", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["Paladin", "Paladin", registryAdd, vrfAdd],
  });

  const monk = await deploy("Monk", {
    from: deployer,
    log: true,
    autoMine: true,
    args: ["Monk", "Monk", registryAdd, vrfAdd],
  });

  const registry = await hre.ethers.getContract("Registry", deployer);
  await registry.addContract(rogue.address, 2);
  await registry.addContract(paladin.address, 2);
  await registry.addContract(monk.address, 2);
  //const gear = await hre.ethers.getContract("Gear", deployer);
  //await registry.addContract(wizard.address, 2);
  //await registry.addContract(barbarian.address, 2);
  //await registry.addContract(dungeon.address, 1);
  //await registry.setGearContract(gear.address);

  //const hat = {
  //  stat: 1,
  //  mod: 10,
  //};
  //const chest = {
  //  stat: 2,
  //  mod: 15,
  //};
  //const boots = {
  //  stat: 3,
  //  mod: 5,
  //};

  ////mint the hat
  //await gear.createGearData([hat], 1);
  ////mint the chest
  //await gear.createGearData([chest], 2);
  ////mint the boots
  //await gear.createGearData([boots], 3);

  //const lootItem1 = {
  //  id: 1,
  //  rangeStart: 1,
  //  rangeEnd: 50,
  //};
  //const lootItem2 = {
  //  id: 2,
  //  rangeStart: 51,
  //  rangeEnd: 75,
  //};
  //const lootItem3 = {
  //  id: 3,
  //  rangeStart: 76,
  //  rangeEnd: 100,
  //};

  //const lootbox = [
  //  lootItem1,
  //  lootItem2,
  //  lootItem3,
  //]

  //await gear.createLootBox(lootbox, 100);
  //await registry.addLootBox(1);
  await registry.addGear(0);
  await registry.addGear(1);
  await registry.addGear(2);
  await registry.addGear(3);
  await registry.addGear(5);
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["YourContract"];
