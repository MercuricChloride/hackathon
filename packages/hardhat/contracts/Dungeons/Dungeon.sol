//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../PlayerSheet.sol";
import "../interfaces/IDungeon.sol";
import "../VRF.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract Gold is ERC20 {
  constructor() ERC20("Gold", "GOLD") {}

  function mint(address to, uint256 amount) public {
    console.log("minting %s", amount);
    console.log("to: %s", to);
    _mint(to, amount);
  }
}

contract Dungeon is IDungeon {

  VRF public vrf;
  Gold public gold;


  enum DungeonStatus {
    Null,
    Won,
    Lost,
    Finalized
  }

  mapping(uint256 => DungeonStatus) public dungeonStatus;
  mapping(uint256 => address) public dungeonOwner;
  uint public dungeonCount;

  constructor(address _vrf, address _gold) {
    vrf = VRF(_vrf);
    gold = Gold(_gold);
  }

  function playDungeon(Party memory party) public override {
    require(party.players.length > 0, "Dungeon: party must have at least one player");

    for(uint i = 0; i < party.players.length; i++){
      require(party.players[i].playerSheet.ownerOf(party.players[i].tokenId) == msg.sender, "Dungeon: player must be the owner of the token");
    }

    dungeonCount++;

    dungeonOwner[dungeonCount] = msg.sender;

    //play the dungeon
    uint attack;
    for(uint i = 0; i < party.players.length; i++){
      attack += party.players[i].playerSheet.getDamage(party.players[i].tokenId);
    }
    console.log("attack: %s", attack);

    // this is just going to be a random number compared against their attack
    uint256 random = vrf.getRandomNumber();
    uint mod;

    if(party.mode == PlayMode.Easy) {
      mod = 10;
    } else if(party.mode == PlayMode.HardCore) {
      mod = 20;
    }

    random = random % mod;

    if(attack > random) {
      console.log("won");
      console.log("dungeonCount: %s", dungeonCount);
      console.log("dungeon owner: %s", dungeonOwner[dungeonCount]);
      console.log("msg.sender: %s", msg.sender);
      dungeonStatus[dungeonCount] = DungeonStatus.Won;
      emit DungeonWon(dungeonCount);
    } else {
      console.log("lost");
      dungeonStatus[dungeonCount] = DungeonStatus.Lost;
      emit DungeonLost(dungeonCount);
    }
  }

  function finalizeDungeon(uint256 dungeonId) public override {
    require(dungeonStatus[dungeonId] != DungeonStatus.Finalized, "Dungeon already claimed");
    address owner = dungeonOwner[dungeonId];

    if(dungeonStatus[dungeonId] == DungeonStatus.Won){
      emit DungeonWon(dungeonId);
      _onDungeonWin(owner);
    } else if(dungeonStatus[dungeonId] == DungeonStatus.Lost) {
      emit DungeonLost(dungeonId);
      _onDungeonLoss(owner);
    }

    dungeonStatus[dungeonId] = DungeonStatus.Finalized;
  }

  function _onDungeonWin(address to) internal {
    gold.mint(to, 100);
  }

  function _onDungeonLoss(address to) internal {
    gold.mint(to, 10);
  }
}
