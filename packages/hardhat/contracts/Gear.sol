//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

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
    Slot slot;
    Modifier[] modifiers;
  }

  mapping(uint id => GearData) public gearData;
  mapping(uint tokenId => uint) public gearToPlayer;
  uint public gearCount;

  event GearCreated(uint id, GearData gearData);
  event GearEquipped(uint tokenId, uint gearId);
  event GearUnequipped(uint tokenId, uint gearId);

  constructor(
    string memory _name,
    string memory _symbol,
    address _registry,
    address _vrf)
  ERC721(_name, _symbol){}

  function createGearItem(GearData calldata _gearData) public {
    gearData[gearCount] = _gearData;
    gearCount++;
  }

}
