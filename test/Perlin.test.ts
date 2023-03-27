import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Calculator, Cities, GameWorld, PerlinNoise, Trigonometry } from "../typechain-types";
import { CoordsStruct } from "../typechain-types/contracts/Core/Calculator";
import * as fs from 'fs'
describe("Distance", function () {
    let contract: Cities;
    let contract2: GameWorld;
    let calculator: Calculator;
    let perlinNoise: PerlinNoise;
    let trigonometry: Trigonometry;
    const zerozero: any = { X: 1, Y: 1, __reserve: [0, 0, 0] }

    async function deployCityAndWorld() {
        console.log('Deploying contracts...');

        // get owner (first account)
        const [owner] = await ethers.getSigners();
        // deploy Cities contract

        const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
        perlinNoise = await PerlinNoise.deploy();
        await perlinNoise.deployed();

        const Trigonometry = await ethers.getContractFactory("Trigonometry");
        trigonometry = await Trigonometry.deploy();
        await trigonometry.deployed();

        const Cities = await ethers.getContractFactory("Cities");
        contract = await upgrades.deployProxy(
            Cities,
            [owner.address, // owner
                "Imaginary Immutable Iguanas", // name
                "III", // symbol
                "https://example-base-uri.com/", // baseURI
                "https://example-contract-uri.com/", // contractURI,
            ethers.constants.AddressZero]
        ) as any;
        await contract.deployed();


        const GameWorld = await ethers.getContractFactory("GameWorld");
        contract2 = await upgrades.deployProxy(GameWorld, [contract.address, ethers.constants.AddressZero, perlinNoise.address]) as any;
        await contract2.deployed()
        // console.log(await contract2.PerlinNoise());

        // grant owner the minter role
        await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
        await contract2.setCities(contract.address)
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


    it("sample plot scores", async function () {
        for (let index = 0; index < 10; index++) {
            const perlinResult = await perlinNoise.noise2d(index * 100, 2 * 100)
            console.log(perlinResult);
        }

        /* console.log(contract2.address);
        console.log(contract2.address);
        console.log(contract2.address); */
        // fs.writeFileSync('./perlin-test.json', JSON.stringify(perlinResult.map(a => a.Weather.toString())))
        // expect(distance.toString()).to.equal("18");
    });


});
