import { ethers, upgrades } from "hardhat";
import { Calculator, Cities, GameWorld, PerlinNoise, Trigonometry, } from "../typechain-types";

async function deploy() {
  // get deployer
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  let contract: Cities;
  let contract2: GameWorld;
  let calculator: Calculator;
  let perlinNoise: PerlinNoise;
  let trigonometry: Trigonometry;
  const [owner] = await ethers.getSigners();

  // check account balance
  console.log(
    "Account balance:",
    ethers.utils.formatEther(await deployer.getBalance())
  );

  const PerlinNoise = await ethers.getContractFactory("PerlinNoise");
  perlinNoise = await PerlinNoise.deploy();
  await perlinNoise.deployed();

  /*  const Trigonometry = await ethers.getContractFactory("Trigonometry");
   trigonometry = await Trigonometry.deploy();
   await trigonometry.deployed();
  */
  const Calc = await ethers.getContractFactory("Calculator");
  calculator = await Calc.deploy(
  );
  await calculator.deployed();

  const Cities = await ethers.getContractFactory("Cities");
  contract = await upgrades.deployProxy(
    Cities,
    [owner.address, // owner
      "Imaginary Immutable Iguanas", // name
      "III", // symbol
      "https://example-base-uri.com/", // baseURI
      "https://example-contract-uri.com/", // contractURI,
    ethers.constants.AddressZero],
  ) as any;
  await contract.deployed();


  const GameWorld = await ethers.getContractFactory("GameWorld");
  contract2 = await upgrades.deployProxy(GameWorld,
    [contract.address, calculator.address, perlinNoise.address],
    {
      kind: "uups"
    }) as any;
  await contract2.deployed()

  // grant owner the minter role
  // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
  await contract2.setCities(contract.address)
  // grant owner the minter role
  // await contract.grantRole(await contract.MINTER_ROLE(), contract2.address);
  console.log(
    contract.address,
    contract2.address, " this."
  );

}

deploy().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
