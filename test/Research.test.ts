import { ethers, upgrades } from "hardhat";
import { expect } from "chai";
import { Buildings, Cities, CityManager, GameWorld, PerlinNoise, ResearchManager, Researchs, Resources, Trigonometry } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { BigNumber } from "ethers";

describe("Resources", function () {
    let cities: Cities;
    let gameWorld: GameWorld;
    let perlinNoise: PerlinNoise;
    let trigonometry: Trigonometry;
    let cityManager: CityManager;
    let resources: Resources;
    let buildings: Buildings;
    let researchManager: ResearchManager;
    let researchs: Researchs;
    const amount = 100;

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


        // grant owner the minter role
        await cities.grantRole(await cities.MINTER_ROLE(), gameWorld.address);
        await gameWorld.setCities(cities.address)
        await gameWorld.setCityManager(cityManager.address)
        await gameWorld.setPerlinNoise(perlinNoise.address)
        await cityManager.setWorld(gameWorld.address)
        await cityManager.setCities(cities.address)
        await cityManager.setBuilding(buildings.address)
        await cityManager.setResources(resources.address)
        await cityManager.setResources(resources.address)
        await resources.addMinter(owner.address, true)
        await resources.addMinter(cityManager.address, true)
        await resources.addMinter(researchManager.address, true)
        return {
            contract: cities, contract2: gameWorld
        }
    }
    const cityId = 2;
    const researchId = 1;
    const researchCenterId = 9;

    before(async function () {
        await deployCityAndWorld()
    });

    it("NFT deployment OK", async function () {
        expect(await cities.name()).to.equal("Imaginary Immutable Iguanas");
        expect(await cities.hasRole(await cities.MINTER_ROLE(), gameWorld.address)).to.equal(true);
    });


    it("Mint city, 1000 resources and upgrade research center.", async function () {
        const [owner] = await ethers.getSigners();

        await gameWorld.createCity({
            X: 1,
            Y: 1
        }, true, 1)

        await resources.addMinter(owner.address, true)
        for (let i = 0; i < 5; i++) {
            await resources.addResource(cityId, i, 1000)
        }
        for (let i = 0; i < 5; i++) {
            expect((await resources.cityResources(cityId, i)).eq(1000)).to.be.true
        }

        await cityManager.upgradeBuilding(cityId, researchCenterId)
        await time.increase(await (await buildings.buildingInfo(researchCenterId)).UpgradeTime[0].toNumber() + 1)
    });

    it("Research codex valid", async function () {
        const res = await researchs.researchInfo(researchId)
        // codex test
        expect(res.ID.eq(researchId)).to.be.true
        expect(res.RequiredResearchId.isZero()).to.be.true
        expect(res.Cost.slice(0, 5).every(a => a.gt(0))).to.be.true

    });

    let balanceBefore: any = {

    };

    it("Finish first research", async function () {
        const res = await researchs.researchInfo(researchId)
        for (let i = 0; i < 5; i++) {
            const resource = (await resources.cityResources(cityId, i))
            balanceBefore[i] = resource
        }
        const tx = await researchManager.beginResearch(cityId, researchId)
        const completiontime = await researchManager.researchTime(cityId, researchId);
        const blockTime = await time.latest()
        expect(completiontime.eq(res.TimeRequired.add(blockTime))).to.be.true;
        const status = await researchManager.isResearched(cityId, researchId);
        expect(status).to.be.false
        await time.increase(res.TimeRequired.add(1));
        const newstatus = await researchManager.isResearched(cityId, researchId);
        expect(newstatus).to.be.true
        const batchStatus = await researchManager.isResearchedBatch(cityId, [researchId, 2]);
        expect(batchStatus[0]).to.be.true
        expect(batchStatus[1]).to.be.false
    });
});
