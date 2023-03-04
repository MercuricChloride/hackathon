//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../PlayerSheet.sol";

interface IGear is IERC721 {

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

  function gearData(uint tokenId) external view returns(GearData calldata);
}
