// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ZombieHelper.sol";

contract ZombieAttack is ZombieHelper {
  uint256 randNonce = 0;
  uint256 attackVictoryProbability = 70;

  function randMod(uint256 _modulus) internal returns(uint256) {
    randNonce++;
    return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
  }

  function attack(uint256 _zombieId, uint256 _targetId) external onlyOwnerOf(_zombieId) {
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie), "Zombie not ready to attack");
    Zombie storage enemyZombie = zombies[_targetId];
    
    uint256 rand = randMod(100);

    // attacker base + weapon
    uint256 attackerPower = attackVictoryProbability + zombieWeaponPower[_zombieId];
    uint256 defenderArmor = zombieArmorPower[_targetId];
    uint256 totalProbability;

    // subtract armor, but ensure a minimum 5% chance to win even against massive armor
    if (attackerPower > defenderArmor + 5) {
        totalProbability = attackerPower - defenderArmor;
    } else {
        totalProbability = 5; 
    }
    
    // cap at 95% maximum win chance
    if (totalProbability > 95) {
        totalProbability = 95;
    }
    // -------------------

    if (rand <= totalProbability) {
      myZombie.winCount++;
      myZombie.level++;
      enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    } else {
      myZombie.lossCount++;
      enemyZombie.winCount++;
      _triggerCooldown(myZombie);
    }
  }
}
