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


    const GameWorld = await ethers.getContractFactory("GameWorld");
    contract2 = await upgrades.upgradeProxy("0xDE5131b42f4c5dFa74c279Eb3EF98c2397b33Ed3", GameWorld,
        {
            kind: "uups"
        }) as any
    await contract2.deployed()

    // const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
    // perlinNoise = await PerlinNoise.deploy()
    // await perlinNoise.deployed()


    // contract2 = await ethers.getContractAt("GameWorld", "0xDE5131b42f4c5dFa74c279Eb3EF98c2397b33Ed3")
    // await contract2.setPerlinNoise(perlinNoise.address)

    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    console.log(
        contract2.address, " this."
    );

}

deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
