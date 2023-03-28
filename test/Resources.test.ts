import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Buildings, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("Resources", function () {
    let cities: Cities;
    let gameWorld: GameWorld;
    let perlinNoise: PerlinNoise;
    let trigonometry: Trigonometry;
    let cityManager: CityManager;
    let resources: Resources;
    let buildings: Buildings;

    async function deployCityAndWorld() {
        console.log('Deploying contracts...');

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
        // console.log(await contract2.PerlinNoise());

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


    async function logProduction(cityId: any) {
        console.log('Resource building levels:');
        console.log((await cityManager.buildingLevels(cityId, 0)).toString());
        console.log((await cityManager.buildingLevels(cityId, 1)).toString());
        console.log((await cityManager.buildingLevels(cityId, 2)).toString());
        console.log((await cityManager.buildingLevels(cityId, 3)).toString());

        console.log(
            `harvestable wood ${(await resources.calculateHarvestableResource(cityId, 1)).toString()}`
        );
        console.log(
            `harvestable food ${(await resources.calculateHarvestableResource(cityId, 2)).toString()}`
        );
        console.log(
            `harvestable iron ${(await resources.calculateHarvestableResource(cityId, 3)).toString()}`
        );
        console.log(
            `harvestable stone ${(await resources.calculateHarvestableResource(cityId, 4)).toString()}`
        );
    }

    it("city resource production starts", async function () {
        console.log((await cities.totalSupply()).toString());
        const [owner] = await ethers.getSigners()

        const cityId = 2;
        await gameWorld.createCity({
            X: 1,
            Y: 1
        }, true, 1)


        await time.increase(1);

        expect((await cityManager.mintTime(cityId)).toNumber(), "minted").to.be.greaterThan(0);
        expect((await cities.ownerOf(cityId)).toLowerCase()).to.be.equal(owner.address.toLowerCase(), "owned")
        console.log("seconds since last tx: ", await resources.getRoundsSince(cityId));
        await logProduction(cityId)
        expect((await resources.calculateHarvestableResource(cityId, 1)).toNumber()).to.be.equal(10);
        console.log("Upgrading building...");
        await cityManager.upgradeBuilding(cityId, 0);
        console.log("seconds since last tx: ", await resources.getRoundsSince(cityId));
        await logProduction(cityId)

        for (let index = 0; index < 50; index++) {
            await time.increase(1);
            console.log("seconds since last tx: ", await resources.getRoundsSince(cityId));
            await logProduction(cityId)
        }
    });


});
