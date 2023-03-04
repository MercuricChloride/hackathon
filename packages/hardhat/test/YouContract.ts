import { expect } from "chai";
import { ethers } from "hardhat";
import { Wizard, VRF, Registry, Barbarian, Gear } from "../typechain-types";

describe("Dungeon Crawler", function () {
  // We define a fixture to reuse the same setup in every test.

  let wizard: Wizard;
  let vrf: VRF;
  let registry: Registry;
  let barbarian: Barbarian;
  let gear: Gear;

  async function registryInit() {
    await registry.addContract(wizard.address, 2);
    await registry.addContract(barbarian.address, 2);
    await registry.setGearContract(gear.address);
  }

  before(async () => {
    const wizardFactory = await ethers.getContractFactory("Wizard");
    const barbarianFactory = await ethers.getContractFactory("Barbarian");
    const vrfFactory = await ethers.getContractFactory("VRF");
    const registryFactory = await ethers.getContractFactory("Registry");
    const gearFactory = await ethers.getContractFactory("Gear");

    vrf = (await vrfFactory.deploy()) as VRF;
    registry = (await registryFactory.deploy()) as Registry;
    wizard = (await wizardFactory.deploy("Wizard", "Wiz", registry.address, vrf.address)) as Wizard;
    barbarian = (await barbarianFactory.deploy("Barbarian", "Barb", registry.address, vrf.address)) as Barbarian;
    gear = (await gearFactory.deploy("Gear", "GEAR", registry.address, vrf.address)) as Gear;

    await wizard.deployed();
  });

  describe("Registry", function () {
    it("Should only be able to add contracts if you are the owner", async function () {
      const [owner, notOwner] = await ethers.getSigners();

      await expect(registry.connect(notOwner).addContract(wizard.address, 2)).to.be.revertedWith(
        "Ownable: caller is not the owner",
      );

      await registry.connect(owner).addContract(wizard.address, 2);

      expect(await registry.classes(wizard.address)).to.equal(true);
    });

    it("Should only be able to add contracts if you are the owner", async function () {
      const [owner, notOwner] = await ethers.getSigners();

      expect(await registry.classes(wizard.address)).to.equal(true);

      await expect(registry.connect(notOwner).removeContract(wizard.address, 2)).to.be.revertedWith(
        "Ownable: caller is not the owner",
      );

      await registry.connect(owner).removeContract(wizard.address, 2);
    });
  });

  describe("Player Sheet", function () {
    it("Should have the right name", async function () {
      expect(await wizard.name()).to.equal("Wizard");
      expect(await barbarian.name()).to.equal("Barbarian");
    });

    it("Should allow a use to mint", async function () {
      const [owner] = await ethers.getSigners();
      await wizard.mint();
      await barbarian.mint();
      expect(await wizard.balanceOf(owner.address)).to.equal(1);
      expect(await barbarian.balanceOf(owner.address)).to.equal(1);
    });

    //it("Should allow a user to update their player after mint", async function () {
    //  const [owner] = await ethers.getSigners();
    //  expect(await wizard.balanceOf(owner.address)).to.equal(1);
    //  expect(await barbarian.balanceOf(owner.address)).to.equal(1);

    //  const wizardStats = await wizard.playerStats(1);
    //  const newStats = [...wizardStats]
    //  console.log(wizardStats);
    //  console.log(newStats);
    //  const {pointsToSpend: points} = wizardStats;

    //  wizardStats['4'] = wizardStats.inteligence+points;
    //  wizardStats['9'] = BigNumber.from(0);

    //  await wizard.finalizePlayer(1, wizardStats);
    //});

    it("Should calculate damage according to class type", async function () {
      const [owner] = await ethers.getSigners();
      expect(await wizard.balanceOf(owner.address)).to.equal(1);
      expect(await barbarian.balanceOf(owner.address)).to.equal(1);
      const { inteligence: wizInt } = await wizard.playerStats(1);
      const { strength: barbStr } = await wizard.playerStats(1);

      const wizDamage = await wizard.getDamage(1);
      const barbDamage = await barbarian.getDamage(1);
      console.log("wizard:\n", wizInt + "\n", wizDamage + "\n");
      console.log("barb:\n", barbStr + "\n", barbDamage + "\n");

      expect(wizInt).to.equal(wizDamage);
      expect(barbStr).to.equal(barbDamage);
    });
  });

  describe("Gear", function () {
    before(async () => {
      await registryInit();
    });

    it("Should allow a user to create a piece of gear", async function () {
      const simpleModifer = {
        stat: 1,
        mod: 10,
      };

      await gear.createGearData([simpleModifer], 1);
      console.log(await gear.readGearData(1));
    });

    // should allow a user to create a loot box
    it("Should allow a user to create a loot box", async function () {
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

      //mint a loot box
      console.log(await gear.openLootBox(0));
    });
  });
});
