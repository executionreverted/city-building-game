import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Calculator, Cities, CityManager, GameWorld, PerlinNoise, Trigonometry } from "../typechain-types";
import { CoordsStruct } from "../typechain-types/contracts/Core/Calculator";
import * as fs from 'fs'
import { Buildings } from "../typechain-types/contracts/City/Building.sol";
describe("Perlin", function () {
    const zerozero: any = { X: 1, Y: 1, }
    let owner: any

    let nft: Cities;
    let world: GameWorld;
    let perlinNoise: PerlinNoise;
    let cityManager: CityManager;
    let buildings: Buildings;

    async function deployCityAndWorld() {
        // console.log('Deploying contracts...');

        // get owner (first account)
        const signer = await ethers.getSigners();
        // signer.forEach(s => console.log(s.address));
        owner = signer[0];


        // get owner (first account)
        // deploy Cities contract
        const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
        perlinNoise = await PerlinNoise.deploy();
        await perlinNoise.deployed();
        const Buildings = await ethers.getContractFactory("Buildings");
        buildings = await upgrades.deployProxy(Buildings, []) as any;
        await buildings.deployed();

        /*   const Trigonometry = await ethers.getContractFactory("Trigonometry");
          trigonometry = await Trigonometry.deploy();
          await trigonometry.deployed();
       */

        const CityManager = await ethers.getContractFactory("CityManager");
        cityManager = await upgrades.deployProxy(CityManager, []) as any;
        await cityManager.deployed();

        const Cities = await ethers.getContractFactory("Cities");
        nft = await upgrades.deployProxy(
            Cities,
            [
                owner.address, // owner
                "Imaginary Immutable Iguanas", // name
                "III", // symbol
                "https://example-base-uri.com/", // baseURI
                "https://example-contract-uri.com/", // contractURI,
                cityManager.address
            ]
        ) as any;
        await nft.deployed();

        const GameWorld = await ethers.getContractFactory("GameWorld");
        world = await upgrades.deployProxy(GameWorld, [nft.address, ethers.constants.AddressZero, perlinNoise.address, cityManager.address]) as any;
        await world.deployed()

    }



    before(async function () {
        await deployCityAndWorld()
    });



    it("Check perlin", async function () {
        let result: any = []

        expect(await world.PerlinNoise()).to.be.eq(perlinNoise.address)
        // for (let x = 500; x < 600; x += 10) {
        //     console.log(x, x + 10);
        //     let r = (await world.scanPlots(x, x + 10, x, x + 10));
        //     console.log(r);
        //     r.forEach(r => result.push(r))
        // }

        fs.writeFileSync('./perlin-test.json', JSON.stringify(result.map(a => a.Climate.toNumber()), null, 1))
    });


});
