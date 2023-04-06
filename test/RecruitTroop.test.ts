import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Buildings, Calculator, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry, Troops, TroopsManager } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("RecruitTroops", function () {
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
    const barracksId = 6;

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
        await resources.addMinter(troopsManager.address, true)
        await resources.addMinter(cityManager.address, true)
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


    it("Upgrade barracks", async function () {
        await cityManager.upgradeBuilding(cityId, barracksId)
        let hasError
        try {
            await cityManager.upgradeBuilding(cityId, barracksId)
        } catch (error) {
            hasError = true
        }
        expect(hasError).to.be.true
        await time.increase(await (await buildings.buildingInfo(barracksId)).UpgradeTime[0].add(1).toNumber());
        const barracksLvL = await cityManager.buildingLevel(cityId, barracksId)
        expect(barracksLvL.eq(1)).to.be.true

    })

    it("Mint 1 soldier", async function () {
        const [owner] = await ethers.getSigners();
        await cityManager.setTroopsManager(troopsManager.address)
        await resources.addMinter(owner.address, true)
        await resources.addMinter(troopsManager.address, true)
        await troopsManager.recruitTroop(cityId, 0, 1)

        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(1)
    });

    it("Reduce population by 10", async function () {
        const [owner] = await ethers.getSigners();
        expect((await cityManager.cityPopulation(cityId)).toNumber()).to.eq(49)
    });

    it("Recruit 2 troops", async function () {
        await troopsManager.recruitTroops(cityId, [0, 0], [1, 1])
    });

    it("Reduce population by 20", async function () {
        expect((await cityManager.cityPopulation(cityId)).toNumber()).to.eq(47)
    });

    it("Calculate army power", async function () {
        const troop = await troops.troopInfo(0)
        const troopAmount = await troopsManager.cityTroops(cityId, 0)
        const power = await calculator.armyPower(cityId)
        expect(power.Atk.eq(troop.Atk.mul(troopAmount)), "invalid Atk").to.be.true;
        expect(power.SiegeAtk.eq(troop.SiegeAtk.mul(troopAmount)), "invalid SiegeAtk").to.be.true;
        expect(power.Def.eq(troop.Def.mul(troopAmount)), "invalid Def").to.be.true;
        expect(power.SiegeDef.eq(troop.SiegeDef.mul(troopAmount)), "invalid SiegeDef").to.be.true;
        expect(power.Capacity.eq(troop.Capacity.mul(troopAmount)), "invalid Capacity").to.be.true;
    });

    it("Update production modifiers again", async function () {
        for (let i = 0; i < 5; i++) {
            const modifier = await resources.cityResourceModifiers(cityId, 0)
            expect(modifier.toNumber()).to.equal(0)
        }
    });

    it("Release troops", async function () {
        await troopsManager.releaseTroops(cityId, [0], [3])
        expect((await cityManager.cityPopulation(cityId)).toNumber()).to.eq(50)
    });

    it("Calculate army power again", async function () {
        const troop = await troops.troopInfo(0)
        const troopAmount = await troopsManager.cityTroops(cityId, 0)
        const power = await calculator.armyPower(cityId)
        expect(power.Atk.isZero(), "invalid Atk").to.be.true;
        expect(power.SiegeAtk.isZero(), "invalid SiegeAtk").to.be.true;
        expect(power.Def.isZero(), "invalid Def").to.be.true;
        expect(power.SiegeDef.isZero(), "invalid SiegeDef").to.be.true;
        expect(power.Capacity.isZero(), "invalid Capacity").to.be.true;
    });
});