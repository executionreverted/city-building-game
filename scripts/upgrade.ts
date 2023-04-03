import { ethers, upgrades } from "hardhat";
import { Calculator, Cities, GameWorld, GameWorld__factory, PerlinNoise, Trigonometry, } from "../typechain-types";

async function deploy() {
    // get deployer
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    let contract: Cities;
    let contract2: GameWorld;
    let calculator: Calculator;
    let perlinNoise: PerlinNoise;
    let trigonometry: Trigonometry;
    const [owner] = await ethers.getSigners();


    /*  const GameWorld = await ethers.getContractFactory("GameWorld");
     contract2 = await upgrades.upgradeProxy("0x853beE0bf2165866Ef9ED616B216596C913Ed47f", GameWorld,
         {
             kind: "uups"
         }) as any
     await contract2.deployed() */

    /*   const Buildings = await ethers.getContractFactory("Buildings");
      let buildings = await upgrades.upgradeProxy("0x276A06c0af9A2124a09B016DD8fccfeB745B56AF", Buildings,
          {
              kind: "uups"
          }) as any
      await buildings.deployed() */

    // const Resources = await ethers.getContractAt("Resources", "0x444Ec510c21cba0f642281da3B003e6137d86c86");
    // Resources.addMinter("0x7BF6bBD844F08B41F711B25617649322A276ec76", true)
    const Resources = await ethers.getContractFactory("Resources");
    let resources = await upgrades.upgradeProxy("0x444Ec510c21cba0f642281da3B003e6137d86c86", Resources,
        {
            kind: "uups"
        }) as any
    await resources.deployed()

    /*  const CityManager = await ethers.getContractFactory("CityManager");
     let cityManager = await upgrades.upgradeProxy("0x7BF6bBD844F08B41F711B25617649322A276ec76", CityManager,
         {
             kind: "uups"
         }) as any
     await cityManager.deployed()
  */
    // const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
    // perlinNoise = await PerlinNoise.deploy()
    // await perlinNoise.deployed()


    // contract2 = await ethers.getContractAt("GameWorld", "0xDE5131b42f4c5dFa74c279Eb3EF98c2397b33Ed3")
    // await contract2.setPerlinNoise(perlinNoise.address)

    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    // console.log(
    //     contract2.address, " this."
    // );

}

deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
