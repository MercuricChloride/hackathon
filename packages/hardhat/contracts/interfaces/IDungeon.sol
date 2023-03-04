//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "../PlayerSheet.sol";

interface IDungeon {

  struct Player {
    PlayerSheet playerSheet; // @todo maybe update this to be an interface
    uint256 tokenId;
  }

  struct Party {
    Player[] players;
  }

  enum PlayMode {
    Null,
    Easy,
    HardCore
  }

  //@notice this function is used to play a dungeon
  function playDungeon(Party memory party) external returns (uint256 dungeonId);

  //@notice this function is used to finalise a dungeon, and penalize or reward the players
  function finaliseDungeon(uint256 dungeonId) external;
}
