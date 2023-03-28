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

        const CityManager = await ethers.getContractFactory("CityManager");
        cityManager = await upgrades.deployProxy(CityManager, []) as any;
        await cityManager.deployed();

        const Cities = await ethers.getContractFactory("Cities");
        contract = await upgrades.deployProxy(
            Cities,
            [owner.address, // owner
                "Imaginary Immutable Iguanas", // name
                "III", // symbol
                "https://example-base-uri.com/", // baseURI
                "https://example-contract-uri.com/", // contractURI,
            cityManager.address]
        ) as any;
        await contract.deployed();


        const GameWorld = await ethers.getContractFactory("GameWorld");
        contract2 = await upgrades.deployProxy(GameWorld, [contract.address, ethers.constants.AddressZero, perlinNoise.address]) as any;
        await contract2.deployed()

        // grant owner the minter role
        await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
        await contract2.setCities(contract.address)
        await cityManager.setCities(contract.address)
        return {
            contract, contract2
        }
    }

    async function deployCalc() {
        console.log('Deploying contracts...');

        // get owner (first account)
        const [owner] = await ethers.getSigners();
        // deploy Cities contract

        const Calc = await ethers.getContractFactory("Calculator");
        calculator = await Calc.deploy();
        await contract.deployed();


    }

    before(async function () {
        await deployCityAndWorld()
        await deployCalc()
    });

    it("NFT deployment OK", async function () {
        expect(await contract.name()).to.equal("Imaginary Immutable Iguanas");
        expect(await contract.hasRole(await contract.MINTER_ROLE(), contract2.address)).to.equal(true);
    });

    it("distance calculation OK", async function () {
        const c1: CoordsStruct = {
            X: 10,
            Y: 35,
        }
        const c2: CoordsStruct = {
            X: 25,
            Y: 25,
        }
        const distance = await calculator.calculateDistance(c1, c2)

        console.log(distance);
        expect(distance.toString()).to.equal("18");
    });


    it("sample plot scores", async function () {
        const perlinResult = await contract2.scanPlots("1", "10", "1", "10")
        perlinResult.forEach(e => console.log(e.Climate.toString()))
        /* console.log(contract2.address);
        console.log(contract2.address);
        console.log(contract2.address); */
        // fs.writeFileSync('./perlin-test.json', JSON.stringify(perlinResult.map(a => a.Weather.toString())))
        // expect(distance.toString()).to.equal("18");
    });


});
