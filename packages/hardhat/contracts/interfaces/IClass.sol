//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IClass {

  // returns the registry address
  function playerSheet() external view returns (address);

  // this function takes in a tokenId and returns the health of the player
  function getHealth(uint256 tokenId) external view returns (uint256);

  // this function takes in a tokenId and returns the health of the player
  function getAttack(uint256 tokenId) external view returns (uint256);
}
