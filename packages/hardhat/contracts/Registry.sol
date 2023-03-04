//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IClass.sol";
import "./interfaces/IDungeon.sol";

contract Registry is Ownable {

  enum AddType {
    Null,
    Dungeon,
    Class,
    Gear
  }

  event ContractAdded(address _address, AddType _type);
  event ContractRemoved(address _address, AddType _type);
  event GearAdded(uint gearId); 
  event GearRemoved(uint gearId);
  event LootBoxAdded(uint lootBoxId);
  event LootBoxRemoved(uint lootBoxId);

  mapping(address dungeonAddress => bool) public dungeons;
  mapping(address classAddress => bool) public classes;
  mapping(uint lootBoxId => bool) public lootBoxes;
  mapping(uint gearId => bool) public gear;

  address public gearContract;

  function setGearContract(address _gearContract) public onlyOwner {
    gearContract = _gearContract;
    emit ContractAdded(_gearContract, AddType.Gear);
  }

  function addContract(address _address, AddType _type) public onlyOwner {
    require(
      _type == AddType.Dungeon || _type == AddType.Class,
      "Invalid type");
    if (_type == AddType.Dungeon) {
      dungeons[_address] = true;
    } else if (_type == AddType.Class) {
      classes[_address] = true;
    }
    emit ContractAdded(_address, _type);
  }

  function removeContract(address _address, AddType _type) public onlyOwner {
    if (_type == AddType.Dungeon) {
      dungeons[_address] = false;
    } else if (_type == AddType.Class) {
      classes[_address] = false;
    }
    emit ContractRemoved(_address, _type);
  }

  function addGear(uint gearId) public onlyOwner {
    gear[gearId] = true;
    emit GearAdded(gearId);
  }

  function removeGear(uint gearId) public onlyOwner {
    gear[gearId] = false;
    emit GearRemoved(gearId);
  }

  function addLootBox(uint lootBoxId) public onlyOwner {
    lootBoxes[lootBoxId] = true;
    emit LootBoxAdded(lootBoxId);
  }

  function removeLootBox(uint lootBoxId) public onlyOwner {
    lootBoxes[lootBoxId] = false;
    emit LootBoxRemoved(lootBoxId);
  }
}
