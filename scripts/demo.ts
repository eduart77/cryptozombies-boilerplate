import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Starting the Full CryptoZombies God-Mode Demo...\n");

  console.log("📦 Deploying ZombieOwnership contract...");
  const ZombieOwnership = await ethers.getContractFactory("ZombieOwnership");
  const zombieOwnership = await ZombieOwnership.deploy() as any;
  await zombieOwnership.waitForDeployment();
  const contractAddress = await zombieOwnership.getAddress();
  console.log(`✅ Contract deployed at: ${contractAddress}\n`);

  console.log("🧟 Minting AlphaZombie (ID: 0)...");
  let tx = await zombieOwnership.createRandomZombie("AlphaZombie");
  await tx.wait();
  
  console.log("🧟 Minting BetaZombie (ID: 1)...");
  tx = await zombieOwnership.createRandomZombie("BetaZombie");
  await tx.wait();
  console.log("✅ Both starting zombies minted!\n");

  const fee = ethers.parseEther("0.001");

  // Equip AlphaZombie
  console.log("⚔️ Leveling up AlphaZombie to Lv. 2...");
  tx = await zombieOwnership.levelUp(0, { value: fee });
  await tx.wait();
  console.log("🗡️ Buying Weapon for AlphaZombie...");
  tx = await zombieOwnership.buyWeapon(0, { value: fee });
  await tx.wait();
  const alphaWeapon = await zombieOwnership.zombieWeaponPower(0);
  console.log(`✅ AlphaZombie got a +${alphaWeapon}% Weapon!`);

  // Equip BetaZombie
  console.log("\n🛡️ Leveling up BetaZombie to Lv. 2...");
  tx = await zombieOwnership.levelUp(1, { value: fee });
  await tx.wait();
  console.log("🛡️ Buying Armor for BetaZombie...");
  tx = await zombieOwnership.buyArmor(1, { value: fee });
  await tx.wait();
  const betaArmor = await zombieOwnership.zombieArmorPower(1);
  console.log(`✅ BetaZombie equipped with a +${betaArmor}% Armor block!\n`);

  // FUSION
  console.log("🧬 FUSING ALPHAZOMBIE AND BETAZOMBIE...");
  tx = await zombieOwnership.fuseZombies(0, 1);
  await tx.wait();

  // Fetch Mutant Stats (ID 2)
  const mutant = await zombieOwnership.zombies(2); 
  const mutantWeapon = await zombieOwnership.zombieWeaponPower(2);
  const mutantArmor = await zombieOwnership.zombieArmorPower(2);

  console.log("\n🎉 === FUSION COMPLETE: MEET YOUR ULTIMATE MUTANT === 🎉");
  console.log(`ID: 2`);
  console.log(`Name: ${mutant.name}`);
  console.log(`Level: ${mutant.level} (Combined from parents)`);
  console.log(`DNA: ${mutant.dna} (Ends in 00!)`);
  console.log(`Inherited Weapon: +${mutantWeapon}%`);
  console.log(`Inherited Armor: +${mutantArmor}%`);
  console.log("=========================================================");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});