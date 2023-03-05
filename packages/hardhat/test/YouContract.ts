import { expect } from "chai";
import { ethers } from "hardhat";
import { Wizard, VRF, Registry, Barbarian, Gear, Dungeon, Gold } from "../typechain-types";

describe("Dungeon Crawler", function () {
  // We define a fixture to reuse the same setup in every test.

  let wizard: Wizard;
  let vrf: VRF;
  let registry: Registry;
  let barbarian: Barbarian;
  let gear: Gear;
  let dungeon: Dungeon;
  let gold: Gold;

  async function registryInit() {
    await registry.addContract(wizard.address, 2);
    await registry.addContract(barbarian.address, 2);
    await registry.addContract(dungeon.address, 1);
    await registry.setGearContract(gear.address);
  }

  async function mintSomeGear() {
    const [owner] = await ethers.getSigners();
    //build some gear structs
    const hat = {
      stat: 1,
      mod: 10,
    };
    const chest = {
      stat: 2,
      mod: 15,
    };
    const boots = {
      stat: 3,
      mod: 5,
    };

    //mint the hat
    await gear.connect(owner).createGearData([hat], 1);
    //mint the chest
    await gear.connect(owner).createGearData([chest], 2);
    //mint the boots
    await gear.connect(owner).createGearData([boots], 3);

    const lootItem1 = {
      id: 1,
      rangeStart: 1,
      rangeEnd: 50,
    };
    const lootItem2 = {
      id: 2,
      rangeStart: 51,
      rangeEnd: 75,
    };
    const lootItem3 = {
      id: 3,
      rangeStart: 76,
      rangeEnd: 100,
    };

    const lootBox = [lootItem1, lootItem2, lootItem3];

    // create the lootbox
    await expect(gear.connect(owner).createLootBox(lootBox, 100)).to.emit(gear, "LootBoxCreated");

    // add the loot box in the treasury
    await registry.addLootBox(1);

    //open a loot box
    await expect(gear.connect(owner).openLootBox(1)).to.emit(gear, "LootBoxOpened");
    await expect(gear.connect(owner).openLootBox(1)).to.emit(gear, "LootBoxOpened");
    await expect(gear.connect(owner).openLootBox(1)).to.emit(gear, "LootBoxOpened");

    expect(await gear.balanceOf(owner.address)).to.equal(3);
  }

  async function updatePlayer() {
    const [owner] = await ethers.getSigners();
    expect(await wizard.balanceOf(owner.address)).to.equal(1);
    expect(await barbarian.balanceOf(owner.address)).to.equal(1);

    const { pointsToSpend } = await wizard.playerStats(1);
    const pointsToSpend2 = (await barbarian.playerStats(1)).pointsToSpend;

    const newStats = {
      // init all stats to 8, and put all points in inteligence
      strength: 8,
      dexterity: 8,
      inteligence: 8 + pointsToSpend,
      constitution: 8,
      wisdom: 8,
      charisma: 8,
      luck: 8,
      pointsToSpend: 0,
      level: 0,
      xp: 0,
    };

    const newStats2 = {
      strength: 8 + pointsToSpend2,
      dexterity: 8,
      inteligence: 8,
      constitution: 8,
      wisdom: 8,
      charisma: 8,
      luck: 8,
      pointsToSpend: 0,
      level: 0,
      xp: 0,
    };

    await wizard.connect(owner).finalizePlayer(1, newStats);
    await barbarian.connect(owner).finalizePlayer(1, newStats2);
  }

  before(async () => {
    const wizardFactory = await ethers.getContractFactory("Wizard");
    const barbarianFactory = await ethers.getContractFactory("Barbarian");
    const vrfFactory = await ethers.getContractFactory("VRF");
    const registryFactory = await ethers.getContractFactory("Registry");
    const gearFactory = await ethers.getContractFactory("Gear");
    const dungeonFactory = await ethers.getContractFactory("Dungeon");
    const goldFactory = await ethers.getContractFactory("Gold");

    vrf = (await vrfFactory.deploy()) as VRF;
    registry = (await registryFactory.deploy()) as Registry;
    wizard = (await wizardFactory.deploy("Wizard", "Wiz", registry.address, vrf.address)) as Wizard;
    barbarian = (await barbarianFactory.deploy("Barbarian", "Barb", registry.address, vrf.address)) as Barbarian;

    gear = (await gearFactory.deploy("Gear", "GEAR", registry.address, vrf.address)) as Gear;
    gold = (await goldFactory.deploy()) as Gold;
    dungeon = (await dungeonFactory.deploy(vrf.address, gold.address)) as Dungeon;

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

    it("Should calculate damage according to class type", async function () {
      const [owner] = await ethers.getSigners();
      expect(await wizard.balanceOf(owner.address)).to.equal(1);
      expect(await barbarian.balanceOf(owner.address)).to.equal(1);
      const { inteligence: wizInt, pointsToSpend } = await wizard.playerStats(1);
      const { strength: barbStr, pointsToSpend: pointsToSpend2 } = await barbarian.playerStats(1);
      expect(wizInt).to.equal(8);
      expect(barbStr).to.equal(8);

      let wizDamage = await wizard.getDamage(1);
      expect(wizDamage).to.equal(8);
      let barbDamage = await barbarian.getDamage(1);
      expect(barbDamage).to.equal(8);

      await updatePlayer();

      wizDamage = await wizard.getDamage(1);
      expect(wizDamage).to.equal(8 + pointsToSpend);

      barbDamage = await barbarian.getDamage(1);
      expect(barbDamage).to.equal(8 + pointsToSpend2);

      wizInt = (await wizard.playerStats(1)).inteligence;
      expect(wizInt).to.equal(8 + pointsToSpend);

      barbStr = (await barbarian.playerStats(1)).strength;
      expect(barbStr).to.equal(8 + pointsToSpend2);
      expect(wizInt).to.equal(wizDamage);
      expect(barbStr).to.equal(barbDamage);
    });

    it("Should allow a player to equip gear", async function () {
      await mintSomeGear();
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
      });

      it("Should allow a user to create and open a loot box", async function () {
        mintSomeGear();
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
      });

      it("Should allow a user to create and open a loot box", async function () {
        mintSomeGear();
      });
    });

    describe("Dungeon", function () {
      it("Should allow a user to play a dungeon", async function () {
        const [owner] = await ethers.getSigners();
        const wizardPlayer = {
          playerSheet: wizard.address,
          tokenId: 1,
        };
        const barbarianPlayer = {
          playerSheet: barbarian.address,
          tokenId: 1,
        };

        const party = {
          players: [wizardPlayer],
          mode: 1,
        };

        const party2 = {
          players: [wizardPlayer, barbarianPlayer],
          mode: 1,
        };

        expect(await dungeon.connect(owner).playDungeon(party)).to.emit(dungeon, "DungeonPlayed");
        expect(await dungeon.finalizeDungeon(1)).to.emit(dungeon, "DungeonWon");
        expect(await gold.balanceOf(owner.address)).to.be.equal(100);

        expect(await dungeon.connect(owner).playDungeon(party2)).to.emit(dungeon, "DungeonPlayed");
        expect(await dungeon.finalizeDungeon(2)).to.emit(dungeon, "DungeonWon");

        expect(await gold.balanceOf(owner.address)).to.be.equal(200);
      });
    });
  });
});
