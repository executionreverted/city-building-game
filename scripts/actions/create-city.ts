import { ethers, upgrades } from "hardhat";
import { Calculator, Cities, Cities__factory, GameWorld, PerlinNoise, Trigonometry, } from "../../typechain-types";

async function deploy() {
    // get deployer
    const [deployer] = await ethers.getSigners();
    let contract2: GameWorld;
    const [owner] = await ethers.getSigners();

    const GameWorld = await ethers.getContractAt("GameWorld", "0x2315C27be0dc7b96C7dC8AEbFF0382c012761707");
    // const CitiesAddress = await GameWorld.Cities()
    // const Cities = await ethers.getContractAt("Cities", CitiesAddress)
    // await Cities.grantRole(await Cities.MINTER_ROLE(), GameWorld.address);
    await GameWorld.createCity({ X: 4, Y: 5 }, true, 1)
    console.log(
        await GameWorld.plotProps({
            X: 4, Y: 5
        })
    );

    // grant owner the minter role
    // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    // grant owner the minter role


}

deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
