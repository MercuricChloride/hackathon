//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../interfaces/IClass.sol";
import "../PlayerSheet.sol";

contract Monk is PlayerSheet {

  constructor(
    string memory _name,
    string memory _symbol,
    address _registry,
    address _vrf)
  PlayerSheet(
      _name,
      _symbol,
      _registry,
      _vrf){}

  function getDamage(uint tokenId) public override view returns(uint8) {
    Stats storage player = playerStats[tokenId];
    return player.strength;
  }

  function getHealth(uint tokenId) public override view returns(uint8) {
    Stats storage player = playerStats[tokenId];
    // TODO Add const bonus
    return player.level * healthPerLevel();
  }

  function healthPerLevel() public pure override returns(uint8) {
    return 7;
  }

  function className() public override pure returns(string memory) {
    return "Monk";
  }
}
