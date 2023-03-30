// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Resource} from "../Resources/ResourceEnums.sol";
import {IResources} from "../Resources/IResources.sol";
import {IBuilding} from "../City/IBuildings.sol";
import {ITroops} from "./ITroops.sol";
import {Troop} from "./TroopsStructs.sol";

contract TroopsManager is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    ICityManager CityManager;
    IResources Resources;
    ITroops Troops;

    mapping(uint => uint[100]) CityTroops;

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setBuilding(address _builds) external onlyOwner {
        Buildings = IBuilding(_builds);
    }

    modifier onlyCityOwner(uint cityId) {
        require(Cities.ownerOf(cityId) == msg.sender, "unauth");
        _;
    }

    function initialize(
        address _cities,
        address _building,
        address _cityManager,
        address _resources,
        address _troops
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        Buildings = IBuilding(_building);
        CityManager = ICityManager(_cityManager);
        Resources = IResources(_resources);
        Troops = ITroops(_troops);
    }

    function recruitTroop(
        uint cityId,
        uint troopId,
        uint amount
    ) external onlyCityOwner(cityId) {
        require(amount > 0, "0");
        // check requirements, burn and set resource modifier
        Troop memory _troop = Troops.troopInfo(troopId);
        int _modifier;
        uint _cityPopulation = CityManager.cityPopulation(cityId);
        uint _population;

        // check population
        for (uint i = 0; i < 5; i++) {
            Resources.spendResource(
                cityId,
                Resource(i),
                _troop.Cost.ResourceCost[i] * amount
            );
            _modifier += _troop.Cost.ResourceModifier * int(amount);
            Resources.updateModifier(cityId, Resource(i), _modifier);
        }

        _population += _troop.Population;

        require(_cityPopulation > _population, "low population");
        CityManager.updateCityPopulation(cityId, _cityPopulation - _population);
        CityTroops[cityId][troopId] += amount;
    }

    function cityTroops(
        uint cityId,
        uint troopId
    ) external view returns (uint) {
        return CityTroops[cityId][troopId];
    }
}
