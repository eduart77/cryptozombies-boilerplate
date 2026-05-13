import { ethers } from "hardhat";

async function main() {
  // Replace this with your actual deployed contract address
  const contractAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F"; 
  
  const ZombieOwnership = await ethers.getContractFactory("ZombieOwnership");
  const zombieOwnership = ZombieOwnership.attach(contractAddress) as any;

  // Replace these with two zombie IDs that you actually own!
  const zombieId1 = 0;
  const zombieId2 = 1; 

  console.log(`Initiating Fusion between Zombie #${zombieId1} and Zombie #${zombieId2}...`);
  
  const tx = await zombieOwnership.fuseZombies(zombieId1, zombieId2);
  await tx.wait();

  console.log("Fusion complete! 🧬");

  // To find our new mutant, we will fetch all zombies owned by our address
  const [owner] = await ethers.getSigners();
  const myZombies = await zombieOwnership.getZombiesByOwner(owner.address);
  
  // The new mutant will be the last one in our array
  const newZombieId = myZombies[myZombies.length - 1];

  // Fetch its stats
  const mutant = await zombieOwnership.zombies(newZombieId);
  const weaponPower = await zombieOwnership.zombieWeaponPower(newZombieId);

  console.log(`\n=== MEET YOUR NEW MUTANT ===`);
  console.log(`ID: ${newZombieId}`);
  console.log(`Name: ${mutant.name}`);
  console.log(`Level: ${mutant.level} (Combined from parents)`);
  console.log(`DNA: ${mutant.dna} (Notice it ends in 00!)`);
  if (weaponPower > 0) {
      console.log(`Inherited Weapon Power: +${weaponPower}%`);
  } else {
      console.log(`Inherited Weapon Power: None`);
  }
  console.log(`============================\n`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});