import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Calculator, Cities, CityManager, GameWorld, PerlinNoise, Trigonometry } from "../typechain-types";
import { CoordsStruct } from "../typechain-types/contracts/Core/Calculator";
import * as fs from 'fs'
describe("Distance", function () {
    let contract: Cities;
    let contract2: GameWorld;
    let calculator: Calculator;
    let perlinNoise: PerlinNoise;
    let trigonometry: Trigonometry;
    let cityManager: CityManager;
    const zerozero: any = { X: 1, Y: 1, __reserve: [0, 0, 0] }

    async function deployCityAndWorld() {
        console.log('Deploying contracts...');

        // get owner (first account)
        const [owner] = await ethers.getSigners();
        // deploy Cities contract

        const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
        perlinNoise = await PerlinNoise.deploy();
        await perlinNoise.deployed();
    }



    before(async function () {
        await deployCityAndWorld()
    });



    it("sample plot scores", async function () {
        for (let index = 0; index < 10; index++) {
            const perlinResult = await perlinNoise.noise2d(index * 100, 2 * 100)
        }
        expect(true).to.be.true
        /* console.log(contract2.address);
        console.log(contract2.address);
        console.log(contract2.address); */
        // fs.writeFileSync('./perlin-test.json', JSON.stringify(perlinResult.map(a => a.Weather.toString())))
        // expect(distance.toString()).to.equal("18");
    });


});
