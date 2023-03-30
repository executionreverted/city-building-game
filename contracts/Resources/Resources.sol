// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Resource} from "./ResourceEnums.sol";
import {IBuilding} from "../City/IBuildings.sol";
import {IResources} from "./IResources.sol";

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

    // modifiers from actions in game to decrease/increase productions
    mapping(uint => int[10]) public CityResourceModifiers;

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

    function claimResource(
        uint cityId,
        Resource resource
    ) external onlyCityOwner(cityId) {
        uint amount = calculateHarvestableResource(cityId, resource);

        if (amount > 0) {
            LastClaims[cityId][uint(resource)] = block.timestamp;
            CityResources[cityId][uint(resource)] += amount;
        } else revert("nothing to claim");
    }

    function claimAllAvailableResources(
        uint cityId
    ) external onlyCityOwner(cityId) {
        for (uint i = 0; i < 5; i++) {
            uint amount = calculateHarvestableResource(cityId, Resource(i));
            if (amount > 0) {
                LastClaims[cityId][i] = block.timestamp;
                CityResources[cityId][i] += amount;
            } else revert("nothing to claim");
        }
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
            buildingLvl = CityManager.buildingLevels(cityId, 1);
        } else if (resource == Resource.FOOD) {
            buildingLvl = CityManager.buildingLevels(cityId, 2);
        } else if (resource == Resource.IRON) {
            buildingLvl = CityManager.buildingLevels(cityId, 3);
        } else if (resource == Resource.STONE) {
            buildingLvl = CityManager.buildingLevels(cityId, 4);
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
            buildingLvl = CityManager.buildingLevels(cityId, 1);
        } else if (resource == Resource.FOOD) {
            buildingLvl = CityManager.buildingLevels(cityId, 2);
        } else if (resource == Resource.IRON) {
            buildingLvl = CityManager.buildingLevels(cityId, 3);
        } else if (resource == Resource.STONE) {
            buildingLvl = CityManager.buildingLevels(cityId, 4);
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
        _rounds = elapsed / 10 minutes;
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
