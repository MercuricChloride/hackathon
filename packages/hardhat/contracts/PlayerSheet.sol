//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Registry.sol";
import "./interfaces/IGear.sol";
import "./VRF.sol";

//TODO:
// Add support for gear from registry
// calculate the gear bonus
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

  struct Gear {
    IGear gearContract;
    uint tokenId;
  }

  VRF public vrf;
  Registry public registry;

  uint256 public totalSupply;

  uint8 public constant STARTING_POINTS = 8;

  mapping(uint256 tokenId => Stats) public playerStats;
  mapping(uint256 tokenId => Gear[5]) public playerGear;

  constructor(string memory _name, string memory _symbol, address _registry, address _vrf)ERC721(_name, _symbol){
    registry = Registry(_registry);
    vrf = VRF(_vrf);
  }

  function mint() public {
    //@todo add some payment here maybe?
    //require(noStat for that tokenId)
    totalSupply++;

    uint tokenId = totalSupply;
    uint8 pointsToSpend = uint8(vrf.getRandomNumber());

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

    playerStats[tokenId] = newStats;
  }

  function levelUp(uint256 tokenId) public {
    require(ownerOf(tokenId) == msg.sender, "You do not own this token");
    // @todo add some payment here maybe?
    // @todo add some logic here to level up the player
  }

  function equipGear(address gearAddress, uint256 tokenId) public {
    require(registry.gear(gearAddress), "This is not a valid gear contract");
  }

  function getGearBonus(uint tokenId) public view returns (Stats memory) {
    // get the player stats
    Stats memory player = playerStats[tokenId];
    // get all gear a player has
    for(uint i; i<5; i++) {
      Gear storage gear = playerGear[tokenId][i];
      uint gearId = gear.tokenId;
       IGear.Modifier[] memory modifiers = gear.gearContract.gearData(gearId).modifiers;
      // loop over each gearModifier for each piece of gear, and add it to the player struct
      for(uint j; j<modifiers.length; j++) {
        IGear.Modifier memory mod = modifiers[j];
        player = addModifierBonus(player, mod);
      }
    }
    // then return the player struct
    return player;
  }

  function addModifierBonus(Stats memory playerStat, IGear.Modifier memory mod) public pure returns(Stats memory) {
    if(mod.stat == IGear.Stat.Constitution) {
      playerStat.constitution += mod.mod;
    }
    return playerStat;
  }

  function getDamage(uint tokenId) public virtual view returns(uint8) {}

  function getHealth(uint tokenId) public virtual view returns(uint8) {}

  function healthPerLevel() public virtual pure returns(uint8) {}

  function className() public virtual pure returns(string memory) {}

}
