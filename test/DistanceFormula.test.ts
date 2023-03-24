import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Calculator, Cities, GameWorld } from "../typechain-types";
import { CoordsStruct } from "../typechain-types/contracts/Core/Calculator";

describe("Distance", function () {
    let contract: Cities;
    let contract2: GameWorld;
    let calculator: Calculator;
    const zerozero: any = { X: 1, Y: 1, __reserve: [0, 0, 0] }

    async function deployCityAndWorld() {
        console.log('Deploying contracts...');

        // get owner (first account)
        const [owner] = await ethers.getSigners();
        // deploy Cities contract

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
        contract2 = await upgrades.deployProxy(GameWorld, [contract.address, ethers.constants.AddressZero]) as any;
        await contract2.deployed()
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
        calculator = await Calc.deploy(
        );
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


});
