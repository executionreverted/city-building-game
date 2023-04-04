import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Buildings, Calculator, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry, Troops, TroopsManager } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("Troops", function () {
    let cities: Cities;
    let calculator: Calculator;
    let gameWorld: GameWorld;
    let perlinNoise: PerlinNoise;
    let trigonometry: Trigonometry;
    let cityManager: CityManager;
    let resources: Resources;
    let buildings: Buildings;
    let troops: Troops;
    let troopsManager: TroopsManager;
    const cityId = 2;
    const cityCoords = {
        X: 1,
        Y: 1
    }

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
        troopsManager = await upgrades.deployProxy(TroopsManager, [cities.address, buildings.address, cityManager.address, resources.address, troops.address, gameWorld.address]) as any;
        await troopsManager.deployed();


        const Calculator = await ethers.getContractFactory("Calculator");
        calculator = await upgrades.deployProxy(Calculator, [troops.address, troopsManager.address]) as any;
        await calculator.deployed();

        // grant owner the minter role
        await cities.grantRole(await cities.MINTER_ROLE(), gameWorld.address);
        await gameWorld.setCities(cities.address)
        await gameWorld.setCityManager(cityManager.address)
        await gameWorld.setPerlinNoise(perlinNoise.address)
        await cityManager.setWorld(gameWorld.address)
        await cityManager.setCities(cities.address)
        await cityManager.setBuilding(buildings.address)
        await cityManager.setResources(resources.address)
        await troopsManager.setCalculator(calculator.address)
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

        await gameWorld.createCity(cityCoords, true, 1)

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

    it("Send squad to coords", async function () {
        const coordsToSend = { X: 1, Y: 2 }
        const foodId = 4;
        let resourceBalance = await resources.cityResources(cityId, foodId)

        await troopsManager.sendSquadTo(cityId, coordsToSend, [0], [1], 0)

        let resourceAfter = await resources.cityResources(cityId, foodId)

        let squad = await troopsManager.squadsById(0)
        const activeSquadsOfCity = await troopsManager.cityActiveSquads(cityId)
        const squadsInPosition = await troopsManager.squadsIdOnWorld(coordsToSend)

        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(0, "soldier sent")
        expect(squad.Active).to.be.false
        expect(activeSquadsOfCity.length).to.equal(1)
        expect(squadsInPosition.length).to.equal(1)
        expect(squadsInPosition[0].eq(0)).to.be.true;
        const distance = await calculator.timeBetweenTwoPoints(cityCoords, coordsToSend)
        // console.log("Distance in seconds: ", distance.toNumber());
        expect(resourceBalance.sub(resourceAfter).eq(distance.mul(5)))
        resourceBalance = await resources.CityResources(cityId, foodId)
        expect(squad.Position.X.eq(coordsToSend.X)).to.be.true
        expect(squad.Position.Y.eq(coordsToSend.Y)).to.be.true
        await time.increase(distance.toNumber() + 1)
        squad = await troopsManager.squadsById(0)
        expect(squad.Active).to.be.true
        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(0)
    });

    it("Get squad to city back", async function () {
        const coordsToSend = { X: 1, Y: 2 }
        const squadId = 0;

        await troopsManager.callSquadBack(cityId, squadId)
        let squad = await troopsManager.squadsById(0)
        const activeSquadsOfCity = await troopsManager.cityActiveSquads(cityId)
        const squadsInPosition = await troopsManager.squadsIdOnWorld(coordsToSend)
        expect(activeSquadsOfCity.length).to.equal(0)
        expect(squadsInPosition.length).to.equal(0)
        // console.log("Distance in seconds: ", distance.toNumber());
        expect(squad.Position.X.eq(0)).to.be.true
        expect(squad.Position.Y.eq(0)).to.be.true
        squad = await troopsManager.squadsById(0)
        expect(!squad.Active).to.be.true
        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(1)
    });
});