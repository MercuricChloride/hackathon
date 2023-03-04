//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Registry.sol";
import "./VRF.sol";
import "./Gear.sol";
//TODO:
//calculate the gear bonus
contract PlayerSheet is ERC721 {

  struct Stats {
    uint8 constitution;
    uint8 dexterity;
    uint8 strength;
    uint8 wisdom;
    uint8 inteligence;
    uint8 charisma;
    uint8 luck;
    uint8 level;
    uint8 pointsToSpend;
    uint256 xp;
  }

  VRF public vrf;
  Registry public registry;

  uint256 public totalSupply;

  uint8 public constant STARTING_POINTS = 8;

  mapping(uint256 tokenId => Stats) public playerStats; 
  mapping(uint256 tokenId => uint[5]) public playerGear; // tokenId -> gearTokenId

  event PlayerMinted(uint256 tokenId, Stats stats, address playerClass, string className);
  event PlayerFinalized(uint256 tokenId, Stats stats);
  event PlayerLeveledUp(uint256 tokenId, Stats stats);
  event GearEquipped(uint256 tokenId, address gearContract, uint gearTokenId);
  event ClassCreated(string className, address classAddress);

  constructor(string memory _name, string memory _symbol, address _registry, address _vrf)ERC721(_name, _symbol){
    registry = Registry(_registry);
    vrf = VRF(_vrf);
    emit ClassCreated(className(), address(this));
  }

  function mint() public {
    //@todo add some payment here maybe?
    //require(noStat for that tokenId)
    totalSupply++;

    uint tokenId = totalSupply;
    uint8 pointsToSpend = (uint8(vrf.getRandomNumber()) % 10) + 20;

    Stats memory stat = Stats(
      STARTING_POINTS, //constitution,
      STARTING_POINTS,// dexterity;
      STARTING_POINTS,// strength;
      STARTING_POINTS,// wisdom;
      STARTING_POINTS,// inteligence;
      STARTING_POINTS,// charisma;
      STARTING_POINTS,// luck;
      uint8(0), //level
      uint8(pointsToSpend), // points to spend
      0 // xp
    );

    // store the players stats for the tokenId
    playerStats[tokenId] = stat;

    emit PlayerMinted(tokenId, stat, address(this), className());
    // @todo add some logic here to create the player
    _safeMint(msg.sender, tokenId);
  }

  function finalizePlayer(uint tokenId, Stats memory newStats) public {
    Stats storage stats = playerStats[tokenId];

    require(stats.pointsToSpend != 0, 'player already finalized');
    require(stats.level == newStats.level, 'invalid level');
    require(stats.xp == newStats.xp, 'invalid xp');

    uint8 constitution = newStats.constitution;
    uint8 dexterity = newStats.dexterity;
    uint8 strength = newStats.strength;
    uint8 wisdom = newStats.wisdom;
    uint8 inteligence = newStats.inteligence;
    uint8 charisma = newStats.charisma;
    uint8 luck = newStats.luck;

    uint8 pointTotal = (
    constitution +
    dexterity +
    strength +
    wisdom +
    inteligence +
    charisma +
    luck);
    uint8 pointsToSpend = stats.pointsToSpend;

    require(pointsToSpend + 48 == pointTotal, 'invalid point distribution');

    emit PlayerFinalized(tokenId, newStats);
    playerStats[tokenId] = newStats;
  }

  function levelUp(uint256 tokenId) public {
    require(ownerOf(tokenId) == msg.sender, "You do not own this token");
    // @todo add some payment here maybe?
    // @todo add some logic here to level up the player
    Stats storage stats = playerStats[tokenId];
    stats.level++;
    stats.pointsToSpend += 5;
    emit PlayerLeveledUp(tokenId, playerStats[tokenId]);
  }

  function equipGear(uint256 playerTokenId, uint gearTokenId, uint slot) public {
    require(registry.gear(gearTokenId), "This is not a valid gear item");
    require(ownerOf(playerTokenId) == msg.sender, "You do not own this token");
    require(Gear(registry.gearContract()).ownerOf(gearTokenId) == msg.sender, "You do not own this gear");
    require(slot < 5, "Invalid slot");
    require(playerGear[playerTokenId][slot] == 0, "Slot already filled");
    (,Gear.Slot _slot) = Gear(registry.gearContract()).readGearData(gearTokenId);
    require(
      uint(_slot) == slot,
      "Invalid slot for this gear"
    );
    playerGear[playerTokenId][slot] = gearTokenId;
  }

  function removeGear(uint256 playerTokenId, uint slot) public {
    require(ownerOf(playerTokenId) == msg.sender, "You do not own this token");
    require(slot < 5, "Invalid slot");
    require(playerGear[playerTokenId][slot] != 0, "Slot already empty");
    playerGear[playerTokenId][slot] = 0;
    emit GearEquipped(playerTokenId, address(0), 0);
  }

  function getGearBonus(uint tokenId) public view returns (Stats memory) {
    // get the player stats
    Stats memory player = playerStats[tokenId];
    // get all gear a player has
    for(uint i; i<5; i++) {
      uint gearId = playerGear[tokenId][i];
       (Gear.Modifier[] memory modifiers,) = Gear(registry.gearContract()).readGearData(gearId);
      // loop over each gearModifier for each piece of gear, and add it to the player struct
      for(uint j; j<modifiers.length; j++) {
        Gear.Modifier memory mod = modifiers[j];
        player = addModifierBonus(player, mod);
      }
    }
    // then return the player struct
    return player;
  }

  function addModifierBonus(Stats memory playerStat, Gear.Modifier memory mod) public pure returns(Stats memory) {
    if(mod.stat == Gear.Stat.Constitution) {
      playerStat.constitution += mod.mod;
    }
    return playerStat;
  }

  function getDamage(uint tokenId) public virtual view returns(uint8) {}

  function getHealth(uint tokenId) public virtual view returns(uint8) {}

  function healthPerLevel() public virtual pure returns(uint8) {}

  function className() public virtual pure returns(string memory) {}
}
