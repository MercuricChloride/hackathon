import { expect } from "chai";
import { ethers } from "hardhat";
import { Wizard, VRF, Registry } from "../typechain-types";

describe("Player Sheet", function () {
  // We define a fixture to reuse the same setup in every test.

  let wizard: Wizard;
  let vrf: VRF;
  let registry: Registry;

  before(async () => {
    const wizardFactory = await ethers.getContractFactory("Wizard");
    const vrfFactory = await ethers.getContractFactory("VRF");
    const registryFactory = await ethers.getContractFactory("Registry");
    vrf = (await vrfFactory.deploy()) as VRF;
    registry = (await registryFactory.deploy()) as Registry;
    wizard = (await wizardFactory.deploy("Wizard", "Wiz", registry.address, vrf.address)) as Wizard;
    await wizard.deployed();
  });

  describe("Deployment", function () {
    it("Should have the right message on deploy", async function () {
      expect(await wizard.name()).to.equal("Wizard");
    });

    it("Should allow a use to mint", async function () {
      const [owner] = await ethers.getSigners();
      await wizard.mint();
      expect(await wizard.balanceOf(owner.address)).to.equal(1);
    });
  });
});
