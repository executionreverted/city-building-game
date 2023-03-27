import { ethers, upgrades } from "hardhat";
import { Calculator, Cities, Cities__factory, GameWorld, PerlinNoise, Trigonometry, } from "../../typechain-types";

async function deploy() {
    // get deployer
    const [deployer] = await ethers.getSigners();
    let contract2: GameWorld;
    const [owner] = await ethers.getSigners();

    const GameWorld = await ethers.getContractAt("GameWorld", "0xE67f5C77323Dc737c26Ce4F30B6B7Deb2B215078");
    // const CitiesAddress = await GameWorld.Cities()
    // const Cities = await ethers.getContractAt("Cities", CitiesAddress)
    // await Cities.grantRole(await Cities.MINTER_ROLE(), GameWorld.address);
    await GameWorld.createCity({ X: 4, Y: 5 }, true, 1)
    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    // grant owner the minter role


}

deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
