//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./VRF.sol";
import "./Registry.sol";

// @note right now we don't have a way to tell what player owns what gear
contract Gear is ERC721 {

  enum Slot {
    Null,
    Head,
    Body,
    Legs,
    Feet,
    Free
  }

  enum Stat {
    Null,
    Constitution,
    Dexterity,
    Strength,
    Wisdom,
    Inteligence,
    Charisma,
    Luck
  }

  struct Modifier {
    Stat stat;
    uint8 mod;
  }

  // the gear data will be stored in the player's sheet
  // we will verify that there isn't any conflict with the slots
  // and use a for loop to calculate the stats for the player based on gear
  struct GearData {
    mapping(uint => Modifier) modifierMap;
    uint modifierLength;
    Slot slot;
  }

  struct LootBoxItem {
    uint id; // the id of the gear
    uint rangeStart;
    uint rangeEnd;
  }

  struct LootBox {
    address createdBy;
    uint rangeMax;
    mapping(uint => LootBoxItem) items;
    uint itemLength;
  }

  mapping(uint id => GearData) public gearData;// registry of available gear data
  mapping(uint lootBoxId => LootBox) public lootBoxes; // registry of available lootboxes
  mapping(uint tokenId => uint) public tokenToGear; // maps from token -> what geardata it is
  //mapping(uint tokenId => uint) public gearToPlayer; @note maybe we don't need this

  uint public gearCount;
  uint public lootBoxCount;
  uint public totalSupply;

  VRF public vrf;
  Registry public registry;

  event GearCreated(uint id, Modifier[] modifiers, Slot slot);
  event GearEquipped(uint tokenId, uint gearId);
  event GearUnequipped(uint tokenId, uint gearId);

  event LootBoxCreated(uint id, LootBoxItem[] items, uint rangeMax);
  event LootBoxOpened(address user, uint lootBoxId, uint gearId);

  constructor(
    string memory _name,
    string memory _symbol,
    address _registry,
    address _vrf)
  ERC721(_name, _symbol){}

  function getGearModifiers(uint tokenId) public view returns(Modifier[] memory) {

    Modifier[] memory modifiers = new Modifier[](gearData[tokenToGear[tokenId]].modifierLength);
    for(uint i = 0; i < gearData[tokenToGear[tokenId]].modifierLength; i++) {
      modifiers[i] = gearData[tokenToGear[tokenId]].modifierMap[i];
    }
    return modifiers;
  }

  function lootBoxItems(uint id) public view returns(LootBoxItem[] memory) {
    LootBox storage box = lootBoxes[id];
    LootBoxItem[] memory items = new LootBoxItem[](box.itemLength);
    for(uint i = 0; i < box.itemLength; i++) {
      items[i] = box.items[i];
    }
    return items;
  }

  function readGearData(uint id) public view returns (Modifier[] memory, Slot) {
    return (getGearModifiers(id), gearData[id].slot);
  }

  function createGearData(Modifier[] calldata modifiers, Slot slot) public {
    uint id = gearCount;
    GearData storage gear = gearData[id];
    gear.modifierLength = modifiers.length;
    for(uint i = 0; i < modifiers.length; i++) {
      gear.modifierMap[i] = modifiers[i];
    }
    gearCount++;
  }

  function createLootBox(LootBoxItem[] calldata items, uint rangeMax) public {
    uint id = lootBoxCount;
    LootBox storage box = lootBoxes[id];
    box.createdBy = msg.sender;
    box.itemLength = items.length;
    for(uint i = 0; i < items.length; i++) {
      box.items[i] = items[i];
    }
    box.rangeMax = rangeMax;
    lootBoxCount++;
    emit LootBoxCreated(id, items, rangeMax);
  }

  function _mintGear(uint gearDataId) internal {
    uint id = totalSupply;
    _safeMint(msg.sender, id);
    tokenToGear[id] = gearDataId;
    totalSupply++;
    (Modifier[] memory modifiers, Slot slot) = readGearData(gearDataId);
    emit GearCreated(gearDataId, modifiers, slot);
  }

  function openLootBox(uint _lootBoxId) public {
    require(registry.lootBoxes(_lootBoxId), "LootBox hasn't been made official yet");

    uint randomNumber = uint(vrf.getRandomNumber()) % lootBoxes[_lootBoxId].rangeMax;
    LootBoxItem[] memory items = lootBoxItems(_lootBoxId);
    for(uint i = 0; i < items.length; i++) {
      LootBoxItem memory item = items[i];
      if(randomNumber >= item.rangeStart && randomNumber <= item.rangeEnd) {
        _mintGear(item.id);
        emit LootBoxOpened(msg.sender, _lootBoxId, item.id);
      }
    }
  }
}
