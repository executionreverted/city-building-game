import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Buildings, Calculator, Cities, CityManager, GameWorld, PerlinNoise, Resources, RNG, Trigonometry, TroopCommands, Troops, TroopsManager } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import "hardhat-gas-reporter"

describe("FieldBattle", function () {
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
    let troopCommands: TroopCommands;
    let rng: RNG
    const cityId = 2;
    const barracksId = 6;

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

        const RNG = await ethers.getContractFactory("RNG");
        rng = await upgrades.deployProxy(RNG, []) as any;
        await rng.deployed();

        const Calculator = await ethers.getContractFactory("Calculator");
        calculator = await upgrades.deployProxy(Calculator, [troops.address, troopsManager.address]) as any;
        await calculator.deployed();


        const TroopCommands = await ethers.getContractFactory("TroopCommands");
        troopCommands = await upgrades.deployProxy(TroopCommands, [
            troopsManager.address,
            cities.address,
            calculator.address,
            troops.address,
            rng.address
        ]) as any;
        await troopCommands.deployed();


        // grant owner the minter role
        await cities.grantRole(await cities.MINTER_ROLE(), gameWorld.address);
        await gameWorld.setCities(cities.address)
        await gameWorld.setCityManager(cityManager.address)
        await gameWorld.setPerlinNoise(perlinNoise.address)
        await cityManager.setWorld(gameWorld.address)
        await cityManager.setCities(cities.address)
        await cityManager.setBuilding(buildings.address)
        await cityManager.setResources(resources.address)
        await cityManager.setTroopsManager(troopsManager.address)
        await troopsManager.setCalculator(calculator.address)
        await resources.addMinter(troopsManager.address, true)
        await resources.addMinter(cityManager.address, true)
        await troopsManager.setTroopCommands(troopCommands.address)
    }

    before(async function () {
        await deployCityAndWorld()
    });

    it("NFT deployment OK", async function () {
        expect(await cities.name()).to.equal("Imaginary Immutable Iguanas");
        expect(await cities.hasRole(await cities.MINTER_ROLE(), gameWorld.address)).to.equal(true);
    });

    it("Mint 10000 resources.", async function () {
        const [owner] = await ethers.getSigners();


        await gameWorld.createCity(cityCoords, true, 1)
        await resources.addMinter(owner.address, true)
        for (let i = 0; i < 5; i++) {
            await resources.addResource(cityId, i, 10000)
        }
        for (let i = 0; i < 4; i++) {
            expect((await resources.cityResources(cityId, i)).eq(10000)).to.be.true
        }
    });

    it("Upgrade barracks", async function () {
        console.log('1');
        console.log("City  Blaances before upgrade: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.CityResources(cityId, index)
            );
        }
        await cityManager.upgradeBuilding(cityId, barracksId)
        console.log('2');
        console.log("City Blaances after upgrade: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.CityResources(cityId, index)
            );
        }
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

    it("Upgrade barracks again", async function () {
        console.log('1');
        console.log("City  Blaances before upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.CityResources(cityId, index)
            );
        }
        await cityManager.upgradeBuilding(cityId, barracksId)
        console.log('2');
        console.log("City Blaances after upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.CityResources(cityId, index)
            );
        }
        let hasError
        try {
            await cityManager.upgradeBuilding(cityId, barracksId)
        } catch (error) {
            hasError = true
        }
        expect(hasError).to.be.true
        await time.increase(await (await buildings.buildingInfo(barracksId)).UpgradeTime[1].add(1).toNumber());
        const barracksLvL = await cityManager.buildingLevel(cityId, barracksId)
        expect(barracksLvL.eq(2)).to.be.true
    })

    it("Upgrade barracks again again", async function () {
        console.log('1');
        console.log("City  Blaances before upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.CityResources(cityId, index)
            );
        }
        await cityManager.upgradeBuilding(cityId, barracksId)
        console.log('2');
        console.log("City Blaances after upgrade2: ");
        for (let index = 0; index < 5; index++) {
            console.log(
                await resources.CityResources(cityId, index)
            );
        }
        let hasError
        try {
            await cityManager.upgradeBuilding(cityId, barracksId)
        } catch (error) {
            hasError = true
        }
        expect(hasError).to.be.true
        await time.increase(await (await buildings.buildingInfo(barracksId)).UpgradeTime[2].add(1).toNumber());
        const barracksLvL = await cityManager.buildingLevel(cityId, barracksId)
        expect(barracksLvL.eq(3)).to.be.true
    })
    it("Mint 100 soldier", async function () {
        const [owner] = await ethers.getSigners();
        await cityManager.setTroopsManager(troopsManager.address)
        await resources.addMinter(owner.address, true)
        await resources.addMinter(troopsManager.address, true)
        await troopsManager.recruitTroop(cityId, 0, 40)
        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(40)
    });

    it("Send squad to coords", async function () {
        const coordsToSend = { X: 1, Y: 2 }
        const foodId = 4;
        let resourceBalance = await resources.cityResources(cityId, foodId)
        const troopToSend = 20
        await troopsManager.sendSquadTo(cityId, coordsToSend, [0], [troopToSend], 2)
        let resourceAfter = await resources.cityResources(cityId, foodId)

        let squad = await troopsManager.squadsById(0)
        const activeSquadsOfCity = await troopsManager.cityActiveSquads(cityId)
        const squadsInPosition = await troopsManager.squadsIdOnWorld(coordsToSend)

        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(40 - troopToSend, "soldier sent")
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
        expect((await troopsManager.cityTroops(cityId, 0)).toNumber()).to.eq(40 - troopToSend)
    });


    it("Send squad 2 to coords", async function () {
        const coordsToSend = { X: 1, Y: 3 }
        const foodId = 4;
        let resourceBalance = await resources.cityResources(cityId, foodId)
        await troopsManager.sendSquadTo(cityId, coordsToSend, [0], [20], 0)
        let resourceAfter = await resources.cityResources(cityId, foodId)

        let squad = await troopsManager.squadsById(1)
        const activeSquadsOfCity = await troopsManager.cityActiveSquads(cityId)
        const squadsInPosition = await troopsManager.squadsIdOnWorld(coordsToSend)

        expect(squad.Active).to.be.false
        expect(activeSquadsOfCity.length).to.equal(2)
        expect(squadsInPosition.length).to.equal(1)
        expect(squadsInPosition[0].eq(1)).to.be.true;
        const distance = await calculator.timeBetweenTwoPoints(cityCoords, coordsToSend)
        // console.log("Distance in seconds: ", distance.toNumber());
        expect(resourceBalance.sub(resourceAfter).eq(distance.mul(5)))
        resourceBalance = await resources.CityResources(cityId, foodId)
        expect(squad.Position.X.eq(coordsToSend.X)).to.be.true
        expect(squad.Position.Y.eq(coordsToSend.Y)).to.be.true
        await time.increase(distance.toNumber() + 1)
        squad = await troopsManager.squadsById(1)
        expect(squad.Active).to.be.true
    });

    it("Attack to squad 2 with squad 1", async function () {
        let squad1 = await troopsManager.squadsById(0)
        let squad2 = await troopsManager.squadsById(1)
        const coordsOfMySquad = { X: 1, Y: 2 }
        const coordsToAttack = { X: 1, Y: 3 }

        for (let index = 0; index < squad1.TroopIds.length; index++) {
            console.log(`squad1 has troop ${index}: ${squad1.TroopAmounts[index].toNumber()}`);
        }
        for (let index = 0; index < squad2.TroopIds.length; index++) {
            console.log(`squad2 has troop ${index}: ${squad2.TroopAmounts[index].toNumber()}`);
        }

        let tx = await troopCommands.attack(0, 0, 1)
        await tx.wait(1)
        const txReceipt = await (cities.provider).getTransactionReceipt(tx.hash);
        console.log(tx.hash);
        let txGasUsed = txReceipt.cumulativeGasUsed
        const gasCostEth = ethers.utils.formatEther(txReceipt.effectiveGasPrice.mul(txReceipt.gasUsed).toNumber());
        console.log({
            txGasUsed, gasUsed: txReceipt.gasUsed, gasPrice: txReceipt.effectiveGasPrice,
            total: txReceipt.effectiveGasPrice.mul(txReceipt.gasUsed).toNumber(),
            gasCostEth
        });

        squad1 = await troopsManager.squadsById(0)
        squad2 = await troopsManager.squadsById(1)
        for (let index = 0; index < squad1.TroopIds.length; index++) {
            console.log(`end of fight squad1 has troop ${index}: ${squad1.TroopAmounts[index].toNumber()}`);
        }
        for (let index = 0; index < squad2.TroopIds.length; index++) {
            console.log(`end of fight squad2 has troop ${index}: ${squad2.TroopAmounts[index].toNumber()}`);
        }




        console.log(
            "squad of atk",
            await troopsManager.squadsIdOnWorld(coordsOfMySquad)
        );
        console.log(
            "squad of def",
            await troopsManager.squadsIdOnWorld(coordsToAttack)
        );

        await time.increase(1000);
        console.log("squad id 0", await (await troopsManager.squadsById(0)).TroopAmounts);
        console.log("squad id 1", await (await troopsManager.squadsById(1)).TroopAmounts);
        console.log("squad of my cities", await troopsManager.cityActiveSquads(cityId));

    })


});