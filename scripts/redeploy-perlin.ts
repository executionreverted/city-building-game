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

    // check account balance
    console.log(
        "Account balance:",
        ethers.utils.formatEther(await deployer.getBalance())
    );

    const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
    perlinNoise = await PerlinNoise.deploy();
    await perlinNoise.deployed();

    /*  const Trigonometry = await ethers.getContractFactory("Trigonometry");
     trigonometry = await Trigonometry.deploy();
     await trigonometry.deployed();
    */



    let GameWorld = await ethers.getContractAt("GameWorld", "0x2315C27be0dc7b96C7dC8AEbFF0382c012761707");
    // @ts-ignore

    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    await GameWorld.setPerlinNoise(perlinNoise.address)
    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    console.log(
    );

}

deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
