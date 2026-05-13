import { ethers } from "hardhat";

async function main() {
  // Replace this with your actual deployed contract address
  const contractAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F"; 
  
  // Connect to the deployed contract
  const ZombieOwnership = await ethers.getContractFactory("ZombieOwnership");
  const zombieOwnership = ZombieOwnership.attach(contractAddress) as any;

  // We are going to buy a weapon for Zombie 0
  const zombieId = 1; 
  const fee = ethers.parseEther("0.001");

  console.log(`Checking if Zombie #${zombieId} is high enough level...`);
  const zombie = await zombieOwnership.zombies(zombieId);
  
  if (zombie.level < 2) {
    console.log(`Zombie is only level ${zombie.level}. Leveling up to 2 first...`);
    const levelUpTx = await zombieOwnership.levelUp(zombieId, { value: fee });
    await levelUpTx.wait();
    console.log("Level up successful!");
  }

  console.log(`Buying weapon for Zombie #${zombieId} for 0.001 ETH...`);
  
  // Call the new buyWeapon function
  const tx = await zombieOwnership.buyWeapon(zombieId, { value: fee });
  await tx.wait();

  // Fetch the new weapon power from the mapping
  const weaponPower = await zombieOwnership.zombieWeaponPower(zombieId);
  console.log(`🎉 Success! Zombie #${zombieId} received a weapon with power: +${weaponPower}% chance to win!`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});