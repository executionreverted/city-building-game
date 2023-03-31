import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Calculator, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry, Troops, TroopsManager } from "../typechain-types";
import { CoordsStruct } from "../typechain-types/contracts/Core/Calculator";
import * as fs from 'fs'
import { Buildings } from "../typechain-types/contracts/City/Building.sol";
describe("Calculator",
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
        // simulation
        const atkArmyPower = [1000, 1500, 2000, 3500, 4000];
        const defArmyPower = [500, 1000, 2000, 5000, 6000];

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

        it("Calculate chances", async function () {

            for (let index = 0; index < atkArmyPower.length; index++) {
                const attackerWinChance = await calculator.attackerVictoryChance(atkArmyPower[index], defArmyPower[index]);
                const defenderWinChance = await calculator.defenderVictoryChance(atkArmyPower[index], defArmyPower[index]);
                console.log(`__________________`);

                console.log(`ATK: ${atkArmyPower[index]} DEF: ${defArmyPower[index]}`);

                console.log(`Attacker win chance: ${attackerWinChance.toNumber() / 10}%`);
                console.log(`Defender win chance: ${defenderWinChance.toNumber() / 10}%`);
                const attackerPlunderAmount = await calculator.plunderAmountPercentage(atkArmyPower[index], defArmyPower[index]);
                console.log(`Max. Plunder resource percentage if attacker win: ${attackerPlunderAmount.toNumber() / 10}% of all resources`)

                const attackerCasualtiesIfWin = await calculator.attackerCasualties(atkArmyPower[index], defArmyPower[index], true, false)
                console.log(`Attacker Casualties if attacker win: ${attackerCasualtiesIfWin.toNumber() / 10}%`);
                const attackerCasualtiesIfLose = await calculator.attackerCasualties(atkArmyPower[index], defArmyPower[index], false, false)
                console.log(`Attacker Casualties if attacker lose: ${attackerCasualtiesIfLose.toNumber() / 10}%`);
                const attackerCasualtiesIfDraw = await calculator.attackerCasualties(atkArmyPower[index], defArmyPower[index], false, true)
                console.log(`Attacker Casualties if draw: ${attackerCasualtiesIfDraw.toNumber() / 10}%`);

                

                const defenderCasualtiesIfWin = await calculator.defenderCasualties(atkArmyPower[index], defArmyPower[index], true, false)
                console.log(`Defender Casualties if attacker win: ${defenderCasualtiesIfWin.toNumber() / 10}%`);
                const defenderCasualtiesIfLose = await calculator.defenderCasualties(atkArmyPower[index], defArmyPower[index], false, false)
                console.log(`Defender Casualties if attacker lose: ${defenderCasualtiesIfLose.toNumber() / 10}%`);
                const defenderCasualtiesIfDraw = await calculator.defenderCasualties(atkArmyPower[index], defArmyPower[index], false, true)
                console.log(`Defender Casualties if draw: ${defenderCasualtiesIfDraw.toNumber() / 10}%`);
           
                console.log(`__________________`);

                expect(defenderWinChance.add(attackerWinChance).eq(1000)).to.be.true
            }
        });
    });
