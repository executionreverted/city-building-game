import { ethers, upgrades } from "hardhat";
import { Calculator, Cities, GameWorld, PerlinNoise, Trigonometry, } from "../typechain-types";

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
    contract2 = await upgrades.upgradeProxy("0xE67f5C77323Dc737c26Ce4F30B6B7Deb2B215078", GameWorld,
        {
            kind: "uups"
        }) as any
    await contract2.deployed()

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
