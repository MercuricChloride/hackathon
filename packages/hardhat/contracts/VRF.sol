//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
contract VRF {
 function getRandomNumber() public view returns (uint256) {
    return uint256(block.timestamp);
 }
}
