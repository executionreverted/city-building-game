import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Buildings, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry, Troops, TroopsManager } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("Troops", function () {
    let cities: Cities;
    let gameWorld: GameWorld;
    let perlinNoise: PerlinNoise;
    let trigonometry: Trigonometry;
    let cityManager: CityManager;
    let resources: Resources;
    let buildings: Buildings;
    let troops: Troops;
    let troopsManager: TroopsManager;
    const cityId = 2;

    async function deployCityAndWorld() {
        // console.log('Deploying contracts...');

        // get owner (first account)
        const [owner] = await ethers.getSigners();
        // deploy Cities contract

        const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
        perlinNoise = await PerlinNoise.deploy();
        await perlinNoise.deployed();

        const Buildings = await ethers.getContractFactory("Buildings");
        buildings = await upgrades.deployProxy(Buildings, []) as any;
        await buildings.deployed();

        const Trigonometry = await ethers.getContractFactory("Trigonometry");
        trigonometry = await Trigonometry.deploy();
        await trigonometry.deployed();

        const CityManager = await ethers.getContractFactory("CityManager");
        cityManager = await upgrades.deployProxy(CityManager, []) as any;
        await cityManager.deployed();

        const Cities = await ethers.getContractFactory("Cities");
        cities = await upgrades.deployProxy(
            Cities,
            [owner.address, // owner
                "Imaginary Immutable Iguanas", // name
                "III", // symbol
                "https://example-base-uri.com/", // baseURI
                "https://example-contract-uri.com/", // contractURI,
            cityManager.address]
        ) as any;
        await cities.deployed();

        const Resources = await ethers.getContractFactory("Resources");
        resources = await upgrades.deployProxy(Resources, [cities.address, buildings.address,
        cityManager.address]) as any;
        await resources.deployed();

        const GameWorld = await ethers.getContractFactory("GameWorld");
        gameWorld = await upgrades.deployProxy(GameWorld, [cities.address, ethers.constants.AddressZero, perlinNoise.address, cityManager.address]) as any;
        await gameWorld.deployed()

        const Troops = await ethers.getContractFactory("Troops");
        troops = await upgrades.deployProxy(Troops, []) as any;
        await troops.deployed();

        const TroopsManager = await ethers.getContractFactory("TroopsManager");
        troopsManager = await upgrades.deployProxy(TroopsManager, [cities.address, buildings.address, cityManager.address, resources.address, troops.address]) as any;
        await troopsManager.deployed();

        // grant owner the minter role
        await cities.grantRole(await cities.MINTER_ROLE(), gameWorld.address);
        await gameWorld.setCities(cities.address)
        await gameWorld.setCityManager(cityManager.address)
        await gameWorld.setPerlinNoise(perlinNoise.address)
        await cityManager.setWorld(gameWorld.address)
        await cityManager.setCities(cities.address)
        await cityManager.setBuilding(buildings.address)
        return {
            contract: cities, contract2: gameWorld
        }
    }

    before(async function () {
        await deployCityAndWorld()
    });

    it("NFT deployment OK", async function () {
        expect(await cities.name()).to.equal("Imaginary Immutable Iguanas");
        expect(await cities.hasRole(await cities.MINTER_ROLE(), gameWorld.address)).to.equal(true);
    });

    it("Mint 1000 resources.", async function () {
        const [owner] = await ethers.getSigners();

        await gameWorld.createCity({
            X: 1,
            Y: 1
        }, true, 1)

        await resources.addMinter(owner.address, true)
        for (let i = 0; i < 5; i++) {
            await resources.addResource(cityId, i, 1000)
        }
        for (let i = 0; i < 4; i++) {
            expect((await resources.cityResources(cityId, i)).eq(1000)).to.be.true
        }
    });


    it("Mint 1 soldier", async function () {
        const [owner] = await ethers.getSigners();
        await cityManager.setTroopsManager(troopsManager.address)
        await resources.addMinter(owner.address, true)
        await resources.addMinter(troopsManager.address, true)
        await troopsManager.recruitTroop(cityId, 0, 1)

        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(1)
    });

    it("Burn proper resources", async function () {
        const [owner] = await ethers.getSigners();

        for (let i = 0; i < 5; i++) {
            expect((await resources.cityResources(cityId, i)).toNumber()).to.eq(900)
        }
    });

    it("Reduce population by 10", async function () {
        const [owner] = await ethers.getSigners();
        expect((await cityManager.cityPopulation(cityId)).toNumber()).to.eq(40)
    });

    it("Update production modifiers", async function () {
        const [owner] = await ethers.getSigners();
        for (let i = 0; i < 5; i++) {
            expect((await resources.cityResourceModifiers(cityId, 0)).eq(-1))
        }
    });

});