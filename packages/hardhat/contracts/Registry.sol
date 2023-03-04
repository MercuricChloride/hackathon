//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IClass.sol";
import "./interfaces/IGear.sol";
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

  mapping(address dungeonAddress => bool) public dungeons;
  mapping(address classAddress => bool) public classes;
  mapping(address gearAddress => bool) public gear;


  function addContract(address _address, AddType _type) public onlyOwner {
    if (_type == AddType.Dungeon) {
      dungeons[_address] = true;
    } else if (_type == AddType.Class) {
      classes[_address] = true;
    } else if (_type == AddType.Gear) {
      gear[_address] = true;
    }
    emit ContractAdded(_address, _type);
  }

  function removeContract(address _address, AddType _type) public onlyOwner {
    if (_type == AddType.Dungeon) {
      dungeons[_address] = false;
    } else if (_type == AddType.Class) {
      classes[_address] = false;
    } else if (_type == AddType.Gear) {
      gear[_address] = false;
    }
    emit ContractRemoved(_address, _type);
  }
}
