import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Calculator, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry, Troops, TroopsManager } from "../typechain-types";
import { CoordsStruct } from "../typechain-types/contracts/Core/Calculator";
import * as fs from 'fs'
import { Buildings } from "../typechain-types/contracts/City/Building.sol";
describe("Distance",
    function () {
        let cities: Cities;
        let gameWorld: GameWorld;
        let calculator: Calculator;
        let perlinNoise: PerlinNoise;
        let trigonometry: Trigonometry;
        let cityManager: CityManager;
        let troops: Troops;
        let troopsManager: TroopsManager;
        let buildings: Buildings;
        let resources: Resources;

        let city1 = 2;
        let city2 = 3;
        async function deployAll() {
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
            return {
                contract: cities, contract2: gameWorld
            }
        }

        before(async function () {
            await deployAll()
        });

        it("Calculate attacker win chance", async function () {
            const atkArmyPower = 1000;
            const defArmyPower = 4000;

            const attackerWinChance = await calculator.attackerVictoryChance(atkArmyPower, defArmyPower);
            const defenderWinChance = await calculator.defenderVictoryChance(atkArmyPower, defArmyPower);
            console.log({ attackerWinChance, defenderWinChance });
            expect(defenderWinChance.add(attackerWinChance).eq(1000)).to.be.true
        });
    });
