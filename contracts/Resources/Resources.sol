// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Resource} from "./ResourceEnums.sol";
import {IBuilding} from "../City/IBuilding.sol";
import "hardhat/console.sol";

contract Resources is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Building;
    ICityManager CityManager;
    /* 
    [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */
    uint[10] BaseProductions;
    mapping(address => bool) public Minters;
    mapping(uint => uint[10]) public LastClaims;
    mapping(uint => uint[10]) public CityResources;

    function initialize(
        address _cities,
        address _buildings,
        address _manager
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        Building = IBuilding(_buildings);
        CityManager = ICityManager(_manager);
        setBaseProductions();
    }

    function setBaseProductions() public onlyOwner {
        BaseProductions[0] = 10;
        BaseProductions[1] = 10;
        BaseProductions[2] = 10;
        BaseProductions[3] = 10;
        BaseProductions[4] = 10;
    }

    function addMinter(address _address, bool val) external onlyOwner {
        Minters[_address] = val;
    }

    modifier onlyMinter() {
        require(Minters[msg.sender], "unauthorized");
        _;
    }

    function addResource(
        uint cityId,
        Resource resource,
        uint amount
    ) external onlyMinter {
        uint amount = calculateHarvestableResource(cityId, resource);

        if (amount > 0) {
            CityResources[cityId][uint(resource)] += amount;
        } else revert("nothing to claim");
    }

    function wrapResource(uint cityId, Resource resource) external onlyMinter {
        // burn resource and wrap it in nft
    }

    function unwrapResource(uint cityId, uint nftId) external onlyMinter {
        // burn nft and unwrap resource
    }

    function claimResource(uint cityId, Resource resource) external {
        address _owner = Cities.ownerOf(cityId);
        require(_owner == msg.sender, "unauthorized");
        uint amount = calculateHarvestableResource(cityId, resource);

        if (amount > 0) {
            CityResources[cityId][uint(resource)] += amount;
        } else revert("nothing to claim");
    }

    function spendResource(
        uint cityId,
        Resource resource,
        uint amount
    ) external onlyMinter {
        if (amount == 0) revert("nothing to burn");
        if (amount > CityResources[cityId][uint(resource)]) revert("exceeds");
        CityResources[cityId][uint(resource)] -= amount;
    }

    function calculateHarvestableResource(
        uint cityId,
        Resource resource
    ) public view returns (uint) {
        uint buildingLvl;
        // check building lvl, check plot info
        if (resource == Resource.WOOD) {
            buildingLvl = CityManager.buildingLevels(cityId, 0);
        } else if (resource == Resource.FOOD) {
            buildingLvl = CityManager.buildingLevels(cityId, 1);
        } else if (resource == Resource.IRON) {
            buildingLvl = CityManager.buildingLevels(cityId, 2);
        } else if (resource == Resource.STONE) {
            buildingLvl = CityManager.buildingLevels(cityId, 3);
        }

        uint rounds = getRoundsSince(cityId);
        if (buildingLvl == 0 || rounds == 0) return 0;
        uint produced = rounds * BaseProductions[uint(resource)];
        return produced + ((produced * (buildingLvl - 1) * 50) / 100);
    }

    function getRoundsSince(uint cityId) public view returns (uint _rounds) {
        uint mintTime = CityManager.mintTime(cityId);
        require(mintTime > 0, "does not exist");
        uint elapsed = block.timestamp - mintTime;
        _rounds = elapsed / 1 seconds;
    }
}
