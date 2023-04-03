import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Buildings, Calculator, Cities, CityManager, GameWorld, PerlinNoise, Trigonometry } from "../typechain-types";
import { config } from "hardhat";

describe("Cities", function () {
  const zerozero: any = { X: 1, Y: 1, }
  let owner: any

  let nft: Cities;
  let world: GameWorld;
  let perlinNoise: PerlinNoise;
  let cityManager: CityManager;
  let buildings: Buildings;

  async function deployCityAndWorld() {
    // console.log('Deploying contracts...');
    const signer = await ethers.getSigners();
    // signer.forEach(s => console.log(s.address));
    owner = signer[0];


    // get owner (first account)
    // deploy Cities contract
    const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
    perlinNoise = await PerlinNoise.deploy();
    await perlinNoise.deployed();
    const Buildings = await ethers.getContractFactory("Buildings");
    buildings = await upgrades.deployProxy(Buildings, []) as any;
    await buildings.deployed();

    /*   const Trigonometry = await ethers.getContractFactory("Trigonometry");
      trigonometry = await Trigonometry.deploy();
      await trigonometry.deployed();
   */

    const CityManager = await ethers.getContractFactory("CityManager");
    cityManager = await upgrades.deployProxy(CityManager, []) as any;
    await cityManager.deployed();

    const Cities = await ethers.getContractFactory("Cities");
    nft = await upgrades.deployProxy(
      Cities,
      [
        owner.address, // owner
        "Imaginary Immutable Iguanas", // name
        "III", // symbol
        "https://example-base-uri.com/", // baseURI
        "https://example-contract-uri.com/", // contractURI,
        cityManager.address
      ]
    ) as any;
    await nft.deployed();

    const GameWorld = await ethers.getContractFactory("GameWorld");
    world = await upgrades.deployProxy(GameWorld, [nft.address, ethers.constants.AddressZero, perlinNoise.address, cityManager.address]) as any;

    // grant owner the minter role
    await nft.grantRole(await nft.MINTER_ROLE(), world.address);
    await nft.grantRole(await nft.MINTER_ROLE(), cityManager.address);
    await cityManager.setCities(nft.address);
    await cityManager.setBuilding(nft.address);
    await cityManager.setWorld(world.address);
    return {
      contract: nft, contract2: world
    }
  }

  before(async function () {
    await deployCityAndWorld()
  });

  it("NFT deployment OK", async function () {
    expect(await nft.name()).to.equal("Imaginary Immutable Iguanas");
    expect(await nft.hasRole(await nft.MINTER_ROLE(), world.address)).to.equal(true);
  });

  it("Plot is empty", async function () {
    expect(await world.isPlotEmpty(zerozero)).to.equal(true);

  });

  it("Create city at [1, -1]", async function () {

    expect(await world.isPlotEmpty(zerozero)).to.equal(true);

    try {
      const tx = await world.createCity(
        zerozero, // desired coords
        true, // pick closest,
        2, { from: owner.address }
      )
      await tx.wait(1);
    } catch (error) {
      // console.log(error);
      // console.log(error);
      // console.log(error);
    } finally {
      // console.log("called 'createCity' method");
    }

    expect(await cityManager.RacePopulation(2)).to.be.equal(1);

    let coords = await world.CityCoords(1)
    // console.log(coords.X.toString(), ",", coords.Y.toString(), '"""');

    expect(await world.isPlotEmpty(zerozero)).to.equal(false);
    // console.log('End of city 1 test.');

  });

  it("Shouldn't allow re-create city in same coords", async function () {

    let hasError = false
    expect(await world.isPlotEmpty(zerozero)).to.equal(false);
    try {
      const tx = await world.createCity(
        zerozero, // desired coords
        false, // pick closest
        1
      )
      await tx.wait(1);
    } catch (error: any) {
      // console.log(error?.message || error?.data);
      hasError = true;
    } finally {
      // console.log("called 'createCity' method for second city");
    }


    let coords = await world.CityCoords(2);
    // console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await world.isPlotEmpty(zerozero)).to.equal(false);
    expect(hasError).to.equal(true);
  });


  it("Create city at [2, 1] by typing 1,1 using closest method", async function () {


    try {
      const tx = await world.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);

      // console.log(error);
    } finally {
      // console.log("called 'createCity' method for third time");
    }
    const isEmpty = await world.isPlotEmpty({ X: 2, Y: 1, });
    const sup = await nft.totalSupply();

    expect(await cityManager.RacePopulation(3)).to.be.equal(1);

    let coords = await world.CityCoords(2)
    // console.log(coords.X.toString(), ",", coords.Y.toString());
    expect(await world.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });


  it("Create city at [2, 2] by typing 1,1 using closest method", async function () {

    try {
      const tx = await world.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      // console.log(error);
    } finally {
      // console.log("called 'createCity' method for fourth time");
    }
    const isEmpty = await world.isPlotEmpty({ X: 2, Y: 2, });
    const sup = await nft.totalSupply();

    let coords = await world.CityCoords(3)
    // console.log(coords.X.toString(), ",", coords.Y.toString());
    expect(await cityManager.RacePopulation(3)).to.be.equal(2);

    expect(await world.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Create city at [3, 2] by typing 1,1 using closest method", async function () {

    try {
      const tx = await world.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);

      // console.log(error);
    } finally {
      // console.log("called 'createCity' method for fifth time");
    }
    const isEmpty = await world.isPlotEmpty({ X: 3, Y: 2, });
    const sup = await nft.totalSupply();

    let coords = await world.CityCoords(4)
    // console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await world.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Create city at [3, 3] by typing 1,1 using closest method", async function () {

    try {
      const tx = await world.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      // console.log(error);
    } finally {
      // console.log("called 'createCity' method for sixth time");
    }
    const isEmpty = await world.isPlotEmpty({ X: 3, Y: 3, });
    const sup = await nft.totalSupply();

    let coords = await world.CityCoords(5)
    // console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await world.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });



  it("Create city at [6, 7] by typing 1,1 using closest method", async function () {

    try {
      const tx = await world.createCity(
        { X: 6, Y: 7, }, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      // console.log(error);
    } finally {
      // console.log("called 'createCity' method for seventh time");
    }
    const isEmpty = await world.isPlotEmpty({ X: 6, Y: 7, });
    const sup = await nft.totalSupply();

    let coords = await world.CityCoords(6)
    // console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await world.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Create city at [7, 7] by typing 6,7 using closest method", async function () {

    try {
      const tx = await world.createCity(
        { X: 6, Y: 7, }, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      // console.log(error);
    } finally {
      // console.log("called 'createCity' method for seventh time");
    }
    const isEmpty = await world.isPlotEmpty({ X: 6, Y: 7, });
    const sup = await nft.totalSupply();

    let coords = await world.CityCoords(7)
    // console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await world.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Cant mint city more far than 100 plots", async function () {
    let hasError;
    try {
      const tx = await world.createCity(
        { X: 200, Y: 200, }, // desired coords
        true, // pick closest
        5
      )
      await tx.wait(1);
    } catch (error) {
      // console.log(error);
      hasError = true;
    } finally {
      // console.log("called 'createCity' method for eighth time");
    }

    expect(hasError).to.equal(true);
  });


  it("Scan and get city infos.", async function () {
    let result = await world.scanCitiesBetweenCoords(0, 10, 0, 10);
    let cities = result[0];
    cities.forEach((city, idx) => {
      if (city.Alive) {
      }
    })
    let cityIds = result[1].filter(a => a.gt(0));
    let cityIdxs = []
    cityIds.forEach(id => {
      cityIdxs.push(result[1].indexOf(id))
    })
    // console.log(cityIds.length);
    expect(cityIds.length).to.equal(7);
  });

  it("Scan and get free plots.", async function () {
    let result = await world.scanPlotsForEmptyPlace(0, 10, 0, 10);
    const isFree = await world.isPlotEmpty(result)
    expect(isFree).to.equal(true);
  });

  it("Get user balance.", async function () {
    const myCities = await cityManager.citiesOf(await nft.owner())

    expect(myCities.length).to.equal(7);
  });

  it("Buildings initiated.", async function () {
    let building
    for (let index = 0; index < 5; index++) {
      building = await cityManager.BuildingLevels(2, 1)
      expect(building.Tier.eq(1)).to.equal(true);
    }
  });

  it("Should claim population.", async function () {

    await cityManager.recruitPopulation(2, { from: owner.address })
    expect((await cityManager.city(2)).Population.toNumber()).to.equal(51);
  });

  it("Should not allow claim population.", async function () {
    let hasError
    try {
      await cityManager.recruitPopulation(2, { from: owner.address })
    } catch (error) {
      // console.log(error);
      hasError = true
    }
    expect(hasError).to.be.true;
  });

});
