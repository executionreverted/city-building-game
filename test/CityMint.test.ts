import { ethers } from "hardhat";
import { expect } from "chai";
import { Cities, GameWorld } from "../typechain-types";

describe("Cities", function () {
  let contract: Cities;
  let contract2: GameWorld;
  const zerozero: any = { X: 1, Y: 1, }

  async function deployCityAndWorld() {
    console.log('Deploying contracts...');

    // get owner (first account)
    const [owner] = await ethers.getSigners();
    // deploy Cities contract

    const Cities = await ethers.getContractFactory("Cities");
    contract = await Cities.deploy(
      owner.address, // owner
      "Imaginary Immutable Iguanas", // name
      "III", // symbol
      "https://example-base-uri.com/", // baseURI
      "https://example-contract-uri.com/", // contractURI,
      ethers.constants.AddressZero
    );
    await contract.deployed();


    const GameWorld = await ethers.getContractFactory("GameWorld");
    contract2 = await GameWorld.deploy(contract.address);

    // grant owner the minter role
    await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
    return {
      contract, contract2
    }
  }

  before(async function () {
    await deployCityAndWorld()
  });

  it("NFT deployment OK", async function () {
    expect(await contract.name()).to.equal("Imaginary Immutable Iguanas");
    expect(await contract.hasRole(await contract.MINTER_ROLE(), contract2.address)).to.equal(true);
  });

  it("Plot is empty", async function () {
    expect(await contract2.isPlotEmpty(zerozero)).to.equal(true);

  });

  it("Create city at [1, -1]", async function () {

    expect(await contract2.isPlotEmpty(zerozero)).to.equal(true);

    try {
      const tx = await contract2.createCity(
        zerozero, // desired coords
        true, // pick closest,
        2
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    } finally {
      console.log("called 'createCity' method");
    }

    let coords = await contract2.CityCoords(1)
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty(zerozero)).to.equal(false);
    console.log('End of city 1 test.');

  });

  it("Shouldn't allow re-create city in same coords", async function () {

    let hasError = false
    expect(await contract2.isPlotEmpty(zerozero)).to.equal(false);
    try {
      const tx = await contract2.createCity(
        zerozero, // desired coords
        false, // pick closest
        1
      )
      await tx.wait(1);
    } catch (error: any) {
      console.log(error?.message || error?.data);
      hasError = true;
    } finally {
      console.log("called 'createCity' method for second city");
    }


    let coords = await contract2.CityCoords(2);
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty(zerozero)).to.equal(false);
    expect(hasError).to.equal(true);
  });


  it("Create city at [2, 1] by typing 1,1 using closest method", async function () {


    try {
      const tx = await contract2.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    } finally {
      console.log("called 'createCity' method for third time");
    }
    const isEmpty = await contract2.isPlotEmpty({ X: 2, Y: 1, });
    const sup = await contract.totalSupply();


    let coords = await contract2.CityCoords(2)
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });


  it("Create city at [2, 2] by typing 1,1 using closest method", async function () {

    try {
      const tx = await contract2.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    } finally {
      console.log("called 'createCity' method for fourth time");
    }
    const isEmpty = await contract2.isPlotEmpty({ X: 2, Y: 2, });
    const sup = await contract.totalSupply();

    let coords = await contract2.CityCoords(3)
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Create city at [3, 2] by typing 1,1 using closest method", async function () {

    try {
      const tx = await contract2.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    } finally {
      console.log("called 'createCity' method for fifth time");
    }
    const isEmpty = await contract2.isPlotEmpty({ X: 3, Y: 2, });
    const sup = await contract.totalSupply();

    let coords = await contract2.CityCoords(4)
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Create city at [3, 3] by typing 1,1 using closest method", async function () {

    try {
      const tx = await contract2.createCity(
        zerozero, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    } finally {
      console.log("called 'createCity' method for sixth time");
    }
    const isEmpty = await contract2.isPlotEmpty({ X: 3, Y: 3, });
    const sup = await contract.totalSupply();

    let coords = await contract2.CityCoords(5)
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });



  it("Create city at [6, 7] by typing 1,1 using closest method", async function () {

    try {
      const tx = await contract2.createCity(
        { X: 6, Y: 7, }, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    } finally {
      console.log("called 'createCity' method for seventh time");
    }
    const isEmpty = await contract2.isPlotEmpty({ X: 6, Y: 7, });
    const sup = await contract.totalSupply();

    let coords = await contract2.CityCoords(6)
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Create city at [7, 7] by typing 6,7 using closest method", async function () {

    try {
      const tx = await contract2.createCity(
        { X: 6, Y: 7, }, // desired coords
        true, // pick closest
        3
      )
      await tx.wait(1);
    } catch (error) {
      console.log(error);
    } finally {
      console.log("called 'createCity' method for seventh time");
    }
    const isEmpty = await contract2.isPlotEmpty({ X: 6, Y: 7, });
    const sup = await contract.totalSupply();

    let coords = await contract2.CityCoords(7)
    console.log(coords.X.toString(), ",", coords.Y.toString());

    expect(await contract2.isPlotEmpty({ X: coords.X, Y: coords.Y, })).to.equal(false);
  });

  it("Scan and get city infos.", async function () {
    let result = await contract2.scanCitiesBetweenCoords(0, 10, 0, 10);
    let cities = result[0];
    cities.forEach(city => {
      if (city.Alive) {
        console.log(city)
      }
    })
    let cityIds = result[1].filter(a => a.gt(0));
    let cityIdxs = []
    cityIds.forEach(id => {
      console.log(`City found with id: ${id}`);
      cityIdxs.push(result[1].indexOf(id))
    })
    console.log(cityIds.length);
    expect(cityIds.length).to.equal(7);
  });

  it("Scan and get free plots.", async function () {
    let result = await contract2.scanPlotsForEmptyPlace(0, 10, 0, 10);
    console.log(result);
    const isEmpty = await contract2.isPlotEmpty({ X: 3, Y: 5, });
    const isFree = await contract2.isPlotEmpty(result)
    console.log(isEmpty, isFree);

    expect(isFree).to.equal(true);
  });

  it("Get user balance.", async function () {
    const myCities = await contract.citiesOf(await contract.owner())

    console.log(myCities);

    expect(myCities.length).to.equal(8);
  });
});
