// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Resource} from "./ResourceEnums.sol";
import {IBuilding} from "../City/IBuildings.sol";
import {Building} from "../City/CityStructs.sol";
import {IResources} from "./IResources.sol";
import "hardhat/console.sol";

contract Resources is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    ICityManager CityManager;

    event ClaimResource(
        uint indexed cityId,
        Resource indexed resourceId,
        uint amount
    );
    event ClaimTax(uint indexed cityId, uint amount);

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

    // modifiers from actions in game to decrease/increase productions
    mapping(uint => int[10]) public CityResourceModifiers;
    uint constant MAX_RESOURCE_ID = 5;
    uint constant PROD_CYCLE = 1 minutes; // todo fix in prod
    uint constant WAREHOUSE_ID = 5;
    uint constant WAREHOUSE_STORAGE_PER_TIER = 250;
    uint constant BASE_GOLD_MAX = 300;
    uint constant BASE_WOOD_MAX = 300;
    uint constant BASE_STONE_MAX = 300;
    uint constant BASE_IRON_MAX = 300;
    uint constant BASE_FOOD_MAX = 300;

    function initialize(
        address _cities,
        address _buildings,
        address _manager
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        Buildings = IBuilding(_buildings);
        CityManager = ICityManager(_manager);
        setBaseProductions();
    }

    function setBaseProductions() public onlyOwner {
        BaseProductions[0] = 100;
        BaseProductions[1] = 100;
        BaseProductions[2] = 100;
        BaseProductions[3] = 100;
        BaseProductions[4] = 100;
    }

    function addMinter(address _address, bool val) external onlyOwner {
        Minters[_address] = val;
    }

    modifier onlyMinter() {
        require(Minters[msg.sender], "unauthorized");
        _;
    }

    modifier onlyCityOwner(uint cityId) {
        address _owner = Cities.ownerOf(cityId);
        require(_owner == msg.sender, "unauthorized");
        _;
    }

    function addResource(
        uint cityId,
        Resource resource,
        uint _amount
    ) external onlyMinter {
        CityResources[cityId][uint(resource)] += _amount;
    }

    function wrapResource(
        uint cityId,
        Resource resource
    ) external onlyCityOwner(cityId) {
        // burn resource and wrap it in nft
    }

    function unwrapResource(
        uint cityId,
        uint nftId
    ) external onlyCityOwner(cityId) {
        // burn nft and unwrap resource
    }

    function claimDailyTax(uint cityId) external onlyCityOwner(cityId) {
        require(block.timestamp > LastClaims[cityId][0] + 23 hours, "early");
        uint amount = claimableGold(cityId);

        LastClaims[cityId][uint(0)] = block.timestamp;
        CityResources[cityId][uint(0)] += amount;

        emit ClaimTax(cityId, amount);
    }

    function claimableGold(uint cityId) public view returns (uint) {
        if (block.timestamp < LastClaims[cityId][0] + 23 hours) return 0;
        return CityManager.cityPopulation(cityId) * BaseProductions[0];
    }

    function claimResource(
        uint cityId,
        Resource resource
    ) external onlyCityOwner(cityId) {
        uint[] memory limits = getCityStorage(cityId);

        _claimSingle(cityId, resource, limits[uint(resource)]);
    }

    function _claimCityGold(uint cityId) internal {
        uint _claimableGold = claimableGold(cityId);
        if (_claimableGold > 0) {
            LastClaims[cityId][uint(0)] = block.timestamp;
            CityResources[cityId][uint(0)] += _claimableGold;
        }
    }

    function claimAllResources(uint cityId) external onlyCityOwner(cityId) {
        uint[] memory limits = getCityStorage(cityId);
        _claimCityGold(cityId);
        for (uint i = 0; i < MAX_RESOURCE_ID; i++) {
            _claimSingle(cityId, Resource(i), limits[uint(i)]);
        }
    }

    function _claimSingle(uint cityId, Resource resource, uint limit) internal {
        uint amount = calculateHarvestableResource(cityId, resource);
        if (amount > 0) {
            if (amount > limit) amount = limit;
            LastClaims[cityId][uint(resource)] = block.timestamp;
            CityResources[cityId][uint(resource)] += amount;
            emit ClaimResource(cityId, resource, amount);
        } else return;
    }

    function getCityStorage(uint cityId) public view returns (uint[] memory) {
        uint[] memory result = new uint[](5);
        uint tier = CityManager.buildingLevel(cityId, WAREHOUSE_ID);

        result[0] = BASE_GOLD_MAX + (WAREHOUSE_STORAGE_PER_TIER * tier);
        result[1] = BASE_WOOD_MAX + (WAREHOUSE_STORAGE_PER_TIER * tier);
        result[2] = BASE_STONE_MAX + (WAREHOUSE_STORAGE_PER_TIER * tier);
        result[3] = BASE_IRON_MAX + (WAREHOUSE_STORAGE_PER_TIER * tier);
        result[4] = BASE_FOOD_MAX + (WAREHOUSE_STORAGE_PER_TIER * tier);

        return (result);
    }

    function spendResources(
        uint cityId,
        uint[] calldata amounts
    ) external onlyMinter {
        uint[] memory limits = getCityStorage(cityId);
        _claimCityGold(cityId);
        for (uint i = 0; i < MAX_RESOURCE_ID; ) {
            _claimSingle(cityId, Resource(i), limits[uint(i)]);

            if (amounts[i] == 0) continue;
            if (amounts[i] > CityResources[cityId][uint(i)]) revert("exceeds");

            CityResources[cityId][uint(i)] -= amounts[i];

            unchecked {
                i++;
            }
        }
    }

    function spendResource(
        uint cityId,
        uint amount,
        Resource resource
    ) external onlyMinter {
        if (amount >= CityResources[cityId][uint(resource)]) revert("exceeds");

        CityResources[cityId][uint(resource)] -= amount;
    }

    function calculateHarvestableResource(
        uint cityId,
        Resource resource
    ) public view returns (uint) {
        uint buildingLvl;
        // check building lvl, check plot info
        if (resource == Resource.WOOD) {
            buildingLvl = CityManager.buildingLevel(cityId, 1);
        } else if (resource == Resource.FOOD) {
            buildingLvl = CityManager.buildingLevel(cityId, 2);
        } else if (resource == Resource.IRON) {
            buildingLvl = CityManager.buildingLevel(cityId, 3);
        } else if (resource == Resource.STONE) {
            buildingLvl = CityManager.buildingLevel(cityId, 4);
        }
        uint productionAmount = productionRate(cityId, resource);
        uint rounds = getRoundsSince(cityId, resource);
        if (buildingLvl == 0 || rounds == 0) return 0;
        uint produced = rounds * productionAmount;
        return produced;
    }

    function productionRate(
        uint cityId,
        Resource resource
    ) public view returns (uint) {
        uint buildingLvl;
        if (resource == Resource.WOOD) {
            buildingLvl = CityManager.buildingLevel(cityId, 1);
        } else if (resource == Resource.FOOD) {
            buildingLvl = CityManager.buildingLevel(cityId, 2);
        } else if (resource == Resource.IRON) {
            buildingLvl = CityManager.buildingLevel(cityId, 3);
        } else if (resource == Resource.STONE) {
            buildingLvl = CityManager.buildingLevel(cityId, 4);
        }
        if (buildingLvl == 0) return 0;
        uint production = BaseProductions[uint(resource)] +
            ((BaseProductions[uint(resource)] * (buildingLvl - 1) * 50) / 100);

        if (CityResourceModifiers[cityId][uint(resource)] > int(production)) {
            return 0;
        }
        return
            uint(
                int(production) + CityResourceModifiers[cityId][uint(resource)]
            );
    }

    function getRoundsSince(
        uint cityId,
        Resource resource
    ) public view returns (uint _rounds) {
        uint lastClaim = LastClaims[cityId][uint(resource)];
        uint mintTime = CityManager.mintTime(cityId);
        require(mintTime > 0, "does not exist");
        uint elapsed = block.timestamp -
            (lastClaim == 0 ? mintTime : lastClaim);
        _rounds = elapsed / PROD_CYCLE;
    }

    function updateModifier(
        uint cityId,
        Resource resource,
        int value
    ) external onlyMinter returns (int _newModifier) {
        CityResourceModifiers[cityId][uint(resource)] += value;
        return CityResourceModifiers[cityId][uint(resource)];
    }

    function cityResourceModifiers(
        uint256 cityId,
        Resource resource
    ) external view returns (int256) {
        return CityResourceModifiers[cityId][uint(resource)];
    }

    function cityResources(
        uint256 cityId,
        Resource resource
    ) external view returns (uint256) {
        return CityResources[cityId][uint(resource)];
    }

    function lastClaims(
        uint256 cityId,
        Resource resource
    ) external view returns (uint256) {
        return LastClaims[cityId][uint(resource)];
    }
}
