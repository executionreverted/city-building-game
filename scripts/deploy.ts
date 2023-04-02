import { ethers, upgrades } from "hardhat";
import { Calculator, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry, Buildings, Troops, TroopsManager } from "../typechain-types";
import * as fs from "fs"
const done = "____ \n deployment done \n ____";
async function deploy() {
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
  // console.log('Deploying contracts...');

  // get owner (first account)
  const [owner] = await ethers.getSigners();
  // deploy Cities contract

  const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
  perlinNoise = await PerlinNoise.deploy();
  await perlinNoise.deployed();

  console.log({ perlinNoise: perlinNoise.address });

  const Buildings = await ethers.getContractFactory("Buildings");
  buildings = await upgrades.deployProxy(Buildings, []) as any;
  await buildings.deployed();

  console.log({ buildings: buildings.address });

  const Trigonometry = await ethers.getContractFactory("Trigonometry");
  trigonometry = await Trigonometry.deploy();
  await trigonometry.deployed();

  console.log({ trigonometry: trigonometry.address });

  const CityManager = await ethers.getContractFactory("CityManager");
  cityManager = await upgrades.deployProxy(CityManager, []) as any;
  await cityManager.deployed();

  console.log({ cityManager: cityManager.address });

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

  console.log({ cities: cities.address });

  const Resources = await ethers.getContractFactory("Resources");
  resources = await upgrades.deployProxy(Resources, [cities.address, buildings.address,
  cityManager.address]) as any;
  await resources.deployed();

  console.log({ resources: resources.address });


  const GameWorld = await ethers.getContractFactory("GameWorld");
  gameWorld = await upgrades.deployProxy(GameWorld, [cities.address, ethers.constants.AddressZero, perlinNoise.address, cityManager.address]) as any;
  await gameWorld.deployed()

  console.log({ gameWorld: gameWorld.address });

  const Troops = await ethers.getContractFactory("Troops");
  troops = await upgrades.deployProxy(Troops, []) as any;
  await troops.deployed();

  console.log({ troops: troops.address });

  const TroopsManager = await ethers.getContractFactory("TroopsManager");
  troopsManager = await upgrades.deployProxy(TroopsManager, [cities.address, buildings.address, cityManager.address, resources.address, troops.address]) as any;
  await troopsManager.deployed();

  console.log({ troopsManager: troopsManager.address });


  const Calculator = await ethers.getContractFactory("Calculator");
  calculator = await upgrades.deployProxy(Calculator, [troops.address, troopsManager.address]) as any;
  await calculator.deployed();

  console.log({ calculator: calculator.address });

  console.log('Giving permissions.');


  // grant owner the minter role
  let tx = await cities.grantRole(await cities.MINTER_ROLE(), gameWorld.address);
  await tx.wait(1)
  tx = await gameWorld.setCities(cities.address)
  await tx.wait(1)
  tx = await gameWorld.setCityManager(cityManager.address)
  await tx.wait(1)
  tx = await gameWorld.setPerlinNoise(perlinNoise.address)
  await tx.wait(1)
  tx = await cityManager.setWorld(gameWorld.address)
  await tx.wait(1)
  tx = await cityManager.setCities(cities.address)
  await tx.wait(1)
  tx = await cityManager.setBuilding(buildings.address)
  await tx.wait(1)

  fs.writeFileSync("./deployed.json", JSON.stringify({
    PerlinNoise: perlinNoise.address,
    Buildings: buildings.address,
    Trigonometry: trigonometry.address,
    CityManager: cityManager.address,
    Cities: cities.address,
    Resources: resources.address,
    GameWorld: gameWorld.address,
    Troops: troops.address,
    TroopsManager: troopsManager.address,
    Calculator: calculator.address,
  }))
}

deploy().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
