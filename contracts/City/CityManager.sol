// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {Building} from "./CityStructs.sol";
import {City} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {ICities} from "./ICities.sol";
import {Resource} from "../Resources/ResourceStructs.sol";
import {IResources} from "../Resources/IResources.sol";
import {IBuilding} from "../City/IBuildings.sol";
import {ICityManager} from "./ICityManager.sol";
import {Coords} from "../World/WorldStructs.sol";
import {ErrorNull, ErrorExceeds, ErrorAssertion, ErrorBadTiming, ErrorUnauthorized} from "../Utils/Errors.sol";

contract CityManager is ICityManager, UpgradeableGameContract {
    event BuildingUpgraded(
        uint indexed cityId,
        uint indexed buildingId,
        uint newTier,
        uint when
    );
    event CityCoordsUpdate(uint indexed cityId, Coords coords);
    event CityRaceUpdate(uint indexed cityId, Race race);
    event CityAliveUpdate(uint indexed cityId, bool value);
    event CityPopulationUpdate(uint indexed cityId, uint population);

    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    IResources Resources;
    mapping(uint => uint) PopulationClaimDates;
    mapping(uint => uint[50]) BuildingLevelActivationTime;
    mapping(uint => City) public CityList;
    mapping(uint => Building[50]) BuildingLevels;
    address GameWorld;
    address TroopsManager;
    uint constant MAX_MATERIAL_ID = 5;
    uint constant MAX_BUILDING_ID = 50;
    uint constant POPULATION_CAP_PER_TOWNHALL_TIER = 100;
    uint[20] public RacePopulation;

    function initialize() external initializer {
        _initialize();
    }

    function setCity(uint cityId, City memory _city) external onlyGame {
        /*   require(
            msg.sender == GameWorld ||
                msg.sender == address(Cities) ||
                msg.sender == address(TroopsManager),
            "!"
        ); */
        CityList[cityId] = _city;
        RacePopulation[uint(_city.Race)]++;
        BuildingLevels[cityId][0].Tier = 1;
        BuildingLevelActivationTime[cityId][0] = block.timestamp;
        BuildingLevels[cityId][1].Tier = 1;
        BuildingLevelActivationTime[cityId][1] = block.timestamp;
        BuildingLevels[cityId][2].Tier = 1;
        BuildingLevelActivationTime[cityId][2] = block.timestamp;
        BuildingLevels[cityId][3].Tier = 1;
        BuildingLevelActivationTime[cityId][3] = block.timestamp;
        BuildingLevels[cityId][4].Tier = 1;
        BuildingLevelActivationTime[cityId][4] = block.timestamp;
    }

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setBuilding(address _builds) external onlyOwner {
        Buildings = IBuilding(_builds);
    }

    function setWorld(address _world) external onlyOwner {
        GameWorld = _world;
    }

    function setResources(address _reso) external onlyOwner {
        Resources = IResources(_reso);
    }

    function setTroopsManager(address _troopsManager) external onlyOwner {
        TroopsManager = _troopsManager;
    }

    modifier onlyGame() {
        if (
            msg.sender != address(Cities) &&
            msg.sender != address(Resources) &&
            msg.sender != (GameWorld) &&
            msg.sender != (TroopsManager)
        ) {
            revert ErrorUnauthorized(msg.sender);
        }
        _;
    }

    modifier onlyCityOwner(uint cityId) {
        if (Cities.ownerOf(cityId) != msg.sender) {
            revert ErrorUnauthorized(msg.sender);
        }
        _;
    }

    function upgradeBuilding(
        uint cityId,
        uint buildingId
    ) external onlyCityOwner(cityId) returns (bool) {
        if (block.timestamp < BuildingLevelActivationTime[cityId][buildingId]) {
            revert ErrorBadTiming(
                BuildingLevelActivationTime[cityId][buildingId],
                block.timestamp
            );
        }

        uint currentTier = BuildingLevels[cityId][buildingId].Tier;
        Building memory _building = Buildings.buildingInfo(buildingId);
        if (_building.MaxTier <= BuildingLevels[cityId][buildingId].Tier) {
            revert ErrorExceeds(_building.MaxTier, currentTier);
        }

        // calculate resources
        uint[] memory _costs = new uint[](MAX_MATERIAL_ID);
        for (uint i = 0; i < MAX_MATERIAL_ID; i++) {
            _costs[i] = _building.Cost[currentTier + 1][i];
        }
        Resources.spendResources(cityId, _costs);
        BuildingLevels[cityId][buildingId].Tier++;
        uint Deadline = block.timestamp + _building.UpgradeTime[currentTier];

        // implement research and reductions
        BuildingLevelActivationTime[cityId][buildingId] = Deadline;

        emit BuildingUpgraded(cityId, buildingId, currentTier + 1, Deadline);
        return true;
    }

    function updateCityCoords(
        uint cityId,
        Coords memory _param
    ) external onlyGame returns (bool) {
        CityList[cityId].Coords = _param;
        emit CityCoordsUpdate(cityId, _param);
        return true;
    }

    function updateCityRace(
        uint cityId,
        Race _param
    ) external onlyGame returns (bool) {
        CityList[cityId].Race = _param;
        RacePopulation[uint(CityList[cityId].Race)]--;
        RacePopulation[uint(_param)]--;
        emit CityRaceUpdate(cityId, _param);
        return true;
    }

    function updateCityAlive(
        uint cityId,
        bool _param
    ) external onlyGame returns (bool) {
        CityList[cityId].Alive = _param;
        emit CityAliveUpdate(cityId, _param);
        return true;
    }

    function updateCityPopulation(
        uint cityId,
        uint _param
    ) external onlyGame returns (bool) {
        CityList[cityId].Population = _param;
        return true;
    }

    function city(uint cityId) external view returns (City memory) {
        return CityList[cityId];
    }

    function cityPopulation(uint cityId) external view returns (uint) {
        return CityList[cityId].Population;
    }

    function buildingLevel(
        uint cityId,
        uint buildingId
    ) external view returns (uint result) {
        result = BuildingLevels[cityId][buildingId].Tier;
        if (result == 0) return result;
        if (block.timestamp < BuildingLevelActivationTime[cityId][buildingId]) {
            result -= 1;
        }
        return result;
    }

    function buildingLevels(
        uint cityId
    ) external view returns (Building[] memory) {
        Building[] memory result = new Building[](MAX_BUILDING_ID);
        for (uint i = 0; i < MAX_BUILDING_ID; ) {
            result[i] = BuildingLevels[cityId][i];
            if (block.timestamp < BuildingLevelActivationTime[cityId][i]) {
                result[i].Tier -= 1;
            }
            unchecked {
                i++;
            }
        }
        return result;
    }

    function recruitPopulation(
        uint cityId
    ) external override onlyCityOwner(cityId) {
        City memory _city = CityList[cityId];
        if (!_city.Alive) {
            revert ErrorAssertion(_city.Alive, false);
        }
        uint _recruitable = calculateRecruitable(cityId);
        if (_recruitable > 0) {
            PopulationClaimDates[cityId] = block.timestamp + 1 days;
            CityList[cityId].Population = _city.Population + _recruitable;
        } else revert ErrorNull(_recruitable);
        emit CityPopulationUpdate(cityId, _city.Population + _recruitable);
    }

    function calculateRecruitable(uint cityId) public view returns (uint) {
        if (block.timestamp < PopulationClaimDates[cityId]) {
            /* revert ErrorBadTiming(
                PopulationClaimDates[cityId],
                block.timestamp
            ); */
            return 0;
        }

        uint _recruitable;
        City memory _city = CityList[cityId];

        uint _townhallTier = BuildingLevels[cityId][0].Tier;
        uint _housingsTier = BuildingLevels[cityId][8].Tier;
        // fetch townhall lvl & housing, give bonus daily population, 4 townhall & 7 housing
        _recruitable += _townhallTier;
        _recruitable += _housingsTier * 2;
        uint cap = _townhallTier * POPULATION_CAP_PER_TOWNHALL_TIER;
        if (_city.Population + _recruitable >= cap) {
            if (_city.Population <= cap) {
                _recruitable = cap - _city.Population;
            } else {
                _recruitable = 0;
            }
        }
        return _recruitable;
    }

    function citiesOf(address player) external view returns (City[] memory) {
        uint bal = Cities.balanceOf(player);
        City[] memory result = new City[](bal);
        uint[] memory _tokensOfOwner = new uint[](bal);
        uint i;
        for (i = 0; i < _tokensOfOwner.length; i++) {
            _tokensOfOwner[i] = Cities.tokenOfOwnerByIndex(player, i);
            result[i] = CityList[_tokensOfOwner[i]];
        }
        return result;
    }

    function mintTime(uint cityId) external view returns (uint) {
        return CityList[cityId].CreationDate;
    }

    function race(uint cityId) external view returns (Race) {
        return CityList[cityId].Race;
    }
}
