import { ethers, upgrades } from "hardhat";
import { Calculator, Cities, CityManager, GameWorld, PerlinNoise, Resources, Trigonometry, Buildings, Troops, TroopsManager, Cities__factory, Researchs, ResearchManager } from "../typechain-types";
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
  let researchs: Researchs;
  let researchManager: ResearchManager;
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
  troopsManager = await upgrades.deployProxy(TroopsManager, [cities.address, buildings.address, cityManager.address, resources.address, troops.address, gameWorld.address]) as any;
  await troopsManager.deployed();

  console.log({ troopsManager: troopsManager.address });


  const Calculator = await ethers.getContractFactory("Calculator");
  calculator = await upgrades.deployProxy(Calculator, [troops.address, troopsManager.address]) as any;
  await calculator.deployed();

  console.log({ calculator: calculator.address });

  const Researchs = await ethers.getContractFactory("Researchs");
  researchs = await upgrades.deployProxy(Researchs, []) as any;
  await researchs.deployed();

  console.log({ researchs: researchs.address });

  const ResearchManager = await ethers.getContractFactory("ResearchManager");
  researchManager = await upgrades.deployProxy(ResearchManager, [
    cities.address, cityManager.address, resources.address, gameWorld.address,
    researchs.address
  ]) as any;
  await researchManager.deployed();

  console.log({ researchManager: researchManager.address });


  console.log('saved deployed.json');

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
    Researchs: researchs.address,
    ResearchManager: researchManager.address,
  }))

  console.log('Giving permissions.');
  /*  const deployed = { "PerlinNoise": "0x50c23c60631dfFDD3e270a654eCD16b853B930b4", "Buildings": "0x8959d23085aFb7720948af3DD9ACCE9F17141083", "Trigonometry": "0x0f7E4a70726b501cf62b929901081640ADC0F3FC", "CityManager": "0x9a2b30bbF92fb53054Fd8fd26e242939E0E8e551", "Cities": "0x19870070c991c983413979E294C10D162680Cc4c", "Resources": "0x84282DB8b1EBc9790709c7954DC421128dD92857", "GameWorld": "0x425AB9e9C28938DC38b3521455CEEC7cda135351", "Troops": "0xB482982FB5790C8A9A29fAD91571Cec5B1Adf84d", "TroopsManager": "0x865E2F154a608a205b7896E93b9a6544AD8602a1", "Calculator": "0x6a73e80468Ef8ecD8D8283C83f2C40518044c569" }
   console.log("Balance: ") */
  // console.log(await owner.getBalance());


  /*   cities = (await ethers.getContractAt("Cities", deployed.Cities, owner))
    gameWorld = await ethers.getContractAt("GameWorld", deployed.GameWorld, owner)
    cityManager = await ethers.getContractAt("CityManager", deployed.CityManager, owner)
    resources = await ethers.getContractAt("Resources", deployed.Resources, owner)
   */
  // grant owner the minter role
  let tx = await cities.grantRole(await cities.MINTER_ROLE(), gameWorld.address, { gasLimit: 7000000 });
  await tx.wait(1)
  console.log(1);

  tx = await gameWorld.setCities(cities.address, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(2);

  // tx = await gameWorld.setCityManager(cityManager.address, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(3);

  // tx = await gameWorld.setPerlinNoise(deployed.PerlinNoise, { gasLimit: 7000000 })
  tx = await gameWorld.setPerlinNoise(perlinNoise.address, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(4);

  tx = await gameWorld.setCalculator(calculator.address, { gasLimit: 7000000 })
  // tx = await gameWorld.setCalculator(deployed.Calculator, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(5);

  tx = await cityManager.setWorld(gameWorld.address, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(6);

  tx = await cityManager.setCities(cities.address, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(7);

  tx = await cityManager.setBuilding(buildings.address, { gasLimit: 7000000 })
  // tx = await cityManager.setBuilding(deployed.Buildings, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(8);

  tx = await cityManager.setResources(resources.address, { gasLimit: 7000000 })
  // tx = await cityManager.setResources(deployed.Resources, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(9);

  tx = await cityManager.setTroopsManager(troopsManager.address, { gasLimit: 7000000 })
  // tx = await cityManager.setTroopsManager(deployed.TroopsManager, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(10);


  // tx = await resources.addMinter(gameWorld.address, true, { gasLimit: 7000000 })
  tx = await resources.addMinter(gameWorld.address, true, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(11);

  tx = await resources.addMinter(cityManager.address, true, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(12);

  tx = await troopsManager.setCalculator(calculator.address, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(13);

  tx = await troopsManager.setCalculator(calculator.address, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(14);

  tx = await resources.addMinter(researchManager.address, true, { gasLimit: 7000000 })
  await tx.wait(1)
  console.log(15);

  console.log(done);
}

deploy().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
