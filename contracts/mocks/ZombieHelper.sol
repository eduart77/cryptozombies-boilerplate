// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ZombieFeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint256 levelUpFee = 0.001 ether;

  modifier aboveLevel(uint256 _level, uint256 _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    (bool success, ) = _owner.call{value: address(this).balance}("");
    require(success, "Transfer failed");
  }

  function setLevelUpFee(uint256 _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint256 _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level++;
  }

  function changeName(uint256 _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint256 _zombieId, uint256 _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint256[] memory) {
    uint256[] memory result = new uint256[](ownerZombieCount[_owner]);
    uint256 counter = 0;
    for (uint256 i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

    //cost of the weapon roll
    uint256 public weaponFee = 0.001 ether;
    mapping(uint256 => uint16) public zombieWeaponPower;
    mapping(uint256 => uint16) public zombieArmorPower;

    // function 1 - fuse
    function fuseZombies(uint256 _zombieId1, uint256 _zombieId2) external onlyOwnerOf(_zombieId1) onlyOwnerOf(_zombieId2) {
      require(_zombieId1 != _zombieId2, "Cannot fuse a zombie with itself");

      // calculate new stats directly to save stack space
      uint256 mutantDna = (zombies[_zombieId1].dna + zombies[_zombieId2].dna) / 2;
      mutantDna = mutantDna - (mutantDna % 100); 
      uint32 combinedLevel = zombies[_zombieId1].level + zombies[_zombieId2].level;

      // calculate strongest gear directly
      uint16 strongestWeapon = zombieWeaponPower[_zombieId1] > zombieWeaponPower[_zombieId2] ? zombieWeaponPower[_zombieId1] : zombieWeaponPower[_zombieId2];
      uint16 strongestArmor = zombieArmorPower[_zombieId1] > zombieArmorPower[_zombieId2] ? zombieArmorPower[_zombieId1] : zombieArmorPower[_zombieId2];

      // burn
      zombieToOwner[_zombieId1] = address(0);
      zombieToOwner[_zombieId2] = address(0);
      ownerZombieCount[msg.sender] -= 2; 

      // clean mappings
      delete zombieWeaponPower[_zombieId1];
      delete zombieWeaponPower[_zombieId2];
      delete zombieArmorPower[_zombieId1];
      delete zombieArmorPower[_zombieId2];

      _createZombie("Mutant", mutantDna);

      // equip mutant
      uint256 newZombieId = zombies.length - 1;
      zombies[newZombieId].level = combinedLevel;
      zombieWeaponPower[newZombieId] = strongestWeapon;
      zombieArmorPower[newZombieId] = strongestArmor;
  }

  // function 2 buy weapon

  function buyWeapon(uint256 _zombieId) external payable onlyOwnerOf(_zombieId) {
    require(msg.value == weaponFee, "Must pay the exact weapon fee");
    require(zombies[_zombieId].level >= 2, "Zombie must be at least level 2 to hold a weapon");

    uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _zombieId))) % 16; 
    
    // so it's not 0
    uint16 newWeaponPower = uint16(rand + 5);  

    zombieWeaponPower[_zombieId] = newWeaponPower;
  }

  function buyArmor(uint256 _zombieId) external payable onlyOwnerOf(_zombieId) {
    require(msg.value == weaponFee, "Must pay the exact fee");
    require(zombies[_zombieId].level >= 2, "Zombie must be at least level 2 to wear armor");

    // added "armor" to the hash so it differs from the weapon roll
    uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _zombieId, "armor"))) % 16; 
    uint16 newArmorPower = uint16(rand + 5); // 5 to 20 power

    zombieArmorPower[_zombieId] = newArmorPower;
  }
  
}
