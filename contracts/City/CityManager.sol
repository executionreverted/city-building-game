// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {Building} from "./CityStructs.sol";
import {City} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {ICities} from "./ICities.sol";
import {IBuilding} from "../City/IBuildings.sol";
import {ICityManager} from "./ICityManager.sol";
import {Coords} from "../World/WorldStructs.sol";

contract CityManager is ICityManager, UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    mapping(uint => uint) PopulationClaimDates;
    mapping(uint => City) public CityList;
    mapping(uint => Building[50]) public BuildingLevels;
    address GameWorld;
    address TroopsManager;

    function initialize() external initializer {
        _initialize();
    }

    function setCity(uint cityId, City memory _city) external {
        require(
            msg.sender == GameWorld ||
                msg.sender == address(Cities) ||
                msg.sender == address(TroopsManager),
            "!"
        );
        CityList[cityId] = _city;
        BuildingLevels[cityId][0].Tier = 1;
        BuildingLevels[cityId][1].Tier = 1;
        BuildingLevels[cityId][2].Tier = 1;
        BuildingLevels[cityId][3].Tier = 1;
        BuildingLevels[cityId][4].Tier = 1;
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

    function setTroopsManager(address _troopsManager) external onlyOwner {
        TroopsManager = _troopsManager;
    }

    modifier onlyCityOwner(uint cityId) {
        require(Cities.ownerOf(cityId) == msg.sender, "unauth");
        _;
    }

    function upgradeBuilding(
        uint cityId,
        uint buildingId
    ) external onlyCityOwner(cityId) returns (bool) {
        Building memory _building = Buildings.buildingInfo(buildingId);
        require(_building.MaxTier > BuildingLevels[cityId][buildingId].Tier);
        BuildingLevels[cityId][buildingId].Tier++;
        return true;
    }

    function updateCityCoords(
        uint cityId,
        Coords memory _param
    ) external onlyCityOwner(cityId) returns (bool) {
        CityList[cityId].Coords = _param;
        return true;
    }

    function updateCityRace(
        uint cityId,
        Race _param
    ) external onlyCityOwner(cityId) returns (bool) {
        CityList[cityId].Race = _param;
        return true;
    }

    function updateCityAlive(
        uint cityId,
        bool _param
    ) external onlyCityOwner(cityId) returns (bool) {
        CityList[cityId].Alive = _param;
        return true;
    }

    function updateCityPopulation(
        uint cityId,
        uint _param
    ) external returns (bool) {
        CityList[cityId].Population = _param;
        return true;
    }

    function city(uint cityId) external view returns (City memory) {
        return CityList[cityId];
    }

    function cityPopulation(uint cityId) external view returns (uint) {
        return CityList[cityId].Population;
    }

    function buildingLevels(
        uint cityId,
        uint buildingId
    ) external view returns (uint) {
        return BuildingLevels[cityId][buildingId].Tier;
    }

    function claimResource(
        uint cityId
    ) external override onlyCityOwner(cityId) {}

    function recruitTroops(
        uint cityId
    ) external override onlyCityOwner(cityId) {}

    function recruitPopulation(
        uint cityId
    ) external override onlyCityOwner(cityId) {
        uint _recruitable;
        require(PopulationClaimDates[cityId] < block.timestamp, "early");
        City memory _city = CityList[cityId];
        uint _townhallTier = BuildingLevels[cityId][0].Tier;
        uint _housingsTier = BuildingLevels[cityId][8].Tier;
        require(_city.Alive, "dead");
        // fetch townhall lvl & housing, give bonus daily population, 4 townhall & 7 housing

        _recruitable += _townhallTier;
        _recruitable += _housingsTier * 2;

        if (_city.Population + _recruitable >= _townhallTier * 75) {
            _recruitable = (_townhallTier * 50) - _city.Population;
        }

        if (_recruitable > 0) {
            PopulationClaimDates[cityId] = block.timestamp + 1 days;
            CityList[cityId].Population = _city.Population + _recruitable;
        } else revert("0");
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
}
