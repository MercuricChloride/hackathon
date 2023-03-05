//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../PlayerSheet.sol";

interface IDungeon {

  struct Player {
    PlayerSheet playerSheet;
    uint256 tokenId;
  }

  struct Party {
    Player[] players;
    PlayMode mode;
  }

  enum PlayMode {
    Null,
    Easy,
    HardCore
  }

  event DungeonPlayed(uint256 dungeonId);
  event DungeonWon(uint256 dungeonId);
  event DungeonLost(uint256 dungeonId);

  //@notice this function is used to play a dungeon
  function playDungeon(Party memory party) external;

  //@notice this function is used to finalise a dungeon, and penalize or reward the players
  function finalizeDungeon(uint256 dungeonId) external;
}
