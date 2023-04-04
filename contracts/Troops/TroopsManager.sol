// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Race} from "../City/CityEnums.sol";
import {Coords} from "../City/CityStructs.sol";
import {IGameWorld} from "../World/IWorld.sol";
import {Resource} from "../Resources/ResourceEnums.sol";
import {IResources} from "../Resources/IResources.sol";
import {IBuilding} from "../City/IBuildings.sol";
import {ITroops} from "./ITroops.sol";
import {ICalculator} from "../Core/ICalculator.sol";
import {Troop, Squad, Purpose} from "./TroopsStructs.sol";
import "hardhat/console.sol";
import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract TroopsManager is UpgradeableGameContract {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    ICityManager CityManager;
    IResources Resources;
    ITroops Troops;
    ICalculator Calculator;
    IGameWorld World;
    uint constant MAX_MATERIAL_ID = 5;
    uint constant FOOD_PER_MINUTE = 5;
    uint constant MAX_SQUADS_ON_PLOT = 10;
    uint constant BARRACKS_ID = 6;

    mapping(uint => uint[100]) CityTroops;
    // movement stuff
    mapping(uint => Squad) SquadsById;
    mapping(int => mapping(int => EnumerableSetUpgradeable.UintSet)) SquadsIdOnWorld;
    mapping(uint => EnumerableSetUpgradeable.UintSet) CityActiveSquads;
    uint squadNonces;

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setBuilding(address _builds) external onlyOwner {
        Buildings = IBuilding(_builds);
    }

    function setCalculator(address _calc) external onlyOwner {
        Calculator = ICalculator(_calc);
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
        address _troops,
        address _world
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        Buildings = IBuilding(_building);
        CityManager = ICityManager(_cityManager);
        Resources = IResources(_resources);
        Troops = ITroops(_troops);
        World = IGameWorld(_world);
    }

    function troopsOfCity(
        uint cityId
    ) external view returns (uint[] memory, uint[] memory) {
        Race race = CityManager.race(cityId);

        // race stuff... determine ids of troops by race
        uint i;
        uint startTroop = 0 * uint(race);
        uint endTroop = 1 * uint(race);

        uint[] memory troopIds = new uint[](endTroop - startTroop);
        uint[] memory amounts = new uint[](endTroop - startTroop);

        for (startTroop; startTroop < endTroop; ) {
            troopIds[i] = startTroop;
            amounts[i] = CityTroops[cityId][startTroop];
            unchecked {
                i++;
                startTroop++;
            }
        }

        return (troopIds, amounts);
    }

    function recruitTroop(
        uint cityId,
        uint troopId,
        uint amount
    ) external onlyCityOwner(cityId) {
        require(amount > 0, "0");
        // check requirements, burn and set resource modifier
        Troop memory _troop = Troops.troopInfo(troopId);
        // int _modifier;
        uint _cityPopulation = CityManager.cityPopulation(cityId);
        uint _population;

        // MinBarracksLevel
        uint barracksLevel = CityManager.buildingLevel(cityId, BARRACKS_ID);
        require(barracksLevel >= _troop.Cost.MinBarracksLevel, "low tier");
        // check population
        uint[] memory _costs = new uint[](MAX_MATERIAL_ID);
        for (uint i = 0; i < MAX_MATERIAL_ID; i++) {
            _costs[i] = _troop.Cost.ResourceCost[i] * amount;
        }

        Resources.spendResources(cityId, _costs);
        // _modifier += _troop.Cost.ResourceModifier * int(amount);
        // Resources.updateModifier(cityId, Resource(i), _modifier);

        _population += _troop.Population * amount;

        require(_cityPopulation >= _population, "low population");
        CityManager.updateCityPopulation(cityId, _cityPopulation - _population);
        CityTroops[cityId][troopId] += amount;
    }

    function recruitTroops(
        uint cityId,
        uint[] calldata troopIds,
        uint[] calldata amounts
    ) external onlyCityOwner(cityId) {
        require(troopIds.length == amounts.length, "mismatch");
        uint _population;
        uint[] memory _costs = new uint[](MAX_MATERIAL_ID);
        for (uint i = 0; i < amounts.length; ) {
            uint amount = amounts[i];
            uint troopId = troopIds[i];
            require(amount > 0, "0");
            // check requirements, burn and set resource modifier
            Troop memory _troop = Troops.troopInfo(troopId);
            // int _modifier;
            // check population

            for (uint y = 0; y < MAX_MATERIAL_ID; y++) {
                _costs[y] += _troop.Cost.ResourceCost[y] * amount;
            }

            _population += _troop.Population * amount;
            CityTroops[cityId][troopId] += amount;
            unchecked {
                i++;
            }
        }

        uint _cityPopulation = CityManager.cityPopulation(cityId);
        require(_cityPopulation >= _population, "low population");
        Resources.spendResources(cityId, _costs);
        CityManager.updateCityPopulation(cityId, _cityPopulation - _population);
    }

    function _releaseTroop(
        uint cityId,
        uint troopId,
        uint amount
    ) internal returns (uint) {
        require(amount > 0, "0");
        require(CityTroops[cityId][troopId] >= amount, "not enough");
        CityTroops[cityId][troopId] -= amount;
        uint _population;
        Troop memory _troop = Troops.troopInfo(troopId);
        _population += _troop.Population * amount;
        return _population;
    }

    function releaseTroops(
        uint cityId,
        uint[] calldata troopIds,
        uint[] calldata amounts
    ) external {
        require(troopIds.length == amounts.length, "mismatch");
        uint population;

        for (uint i = 0; i < troopIds.length; i++) {
            population += _releaseTroop(cityId, troopIds[i], amounts[i]);
        }

        uint _cityPopulation = CityManager.cityPopulation(cityId);

        CityManager.updateCityPopulation(cityId, _cityPopulation + population);
    }

    function cityTroops(
        uint cityId,
        uint troopId
    ) external view returns (uint) {
        return CityTroops[cityId][troopId];
    }

    function sendSquadTo(
        uint cityId,
        Coords memory coords,
        uint[] memory troopIds,
        uint[] memory troopAmounts,
        Purpose purpose
    ) external onlyCityOwner(cityId) {
        require(!hasDupes(troopIds), "has dupes");
        require(troopIds.length == troopAmounts.length, "mismatch");
        require(
            SquadsIdOnWorld[coords.X][coords.Y].length() <= MAX_SQUADS_ON_PLOT,
            "plot capacity reached"
        );
        // limit squads on a coordinate point

        checkTroops(cityId, troopIds, troopAmounts);
        reduceTroopsInTown(cityId, troopIds, troopAmounts);
        Coords memory cityCoords = World.CityCoords(cityId);
        uint timeBetweenCoords = Calculator.timeBetweenTwoPoints(
            cityCoords,
            coords
        );

        // burn food
        Resources.spendResource(
            cityId,
            FOOD_PER_MINUTE + (timeBetweenCoords * FOOD_PER_MINUTE),
            Resource.FOOD
        );

        Squad memory newSquad = Squad({
            TroopIds: troopIds,
            TroopAmounts: troopAmounts,
            Position: coords,
            Purpose: purpose,
            ActiveAfter: block.timestamp + timeBetweenCoords,
            Active: false
        });

        SquadsById[squadNonces] = newSquad;
        SquadsIdOnWorld[coords.X][coords.Y].add(squadNonces);
        CityActiveSquads[cityId].add(squadNonces);
        squadNonces++;
    }

    function callSquadBack(
        uint cityId,
        uint squadId
    ) external onlyCityOwner(cityId) {
        require(CityActiveSquads[cityId].contains(squadId), "invalid squad");
        // todo check other stuff like return half road etc.

        for (uint i = 0; i < SquadsById[squadId].TroopIds.length; i++) {
            CityTroops[cityId][SquadsById[squadId].TroopIds[i]] += SquadsById[
                squadId
            ].TroopAmounts[i];
        }

        SquadsIdOnWorld[SquadsById[squadId].Position.X][
            SquadsById[squadId].Position.Y
        ].remove(squadId);
        CityActiveSquads[cityId].remove(squadId);
        delete SquadsById[squadId];
    }

    function reduceTroopsInTown(
        uint cityId,
        uint[] memory troopIds,
        uint[] memory troopAmounts
    ) internal {
        for (uint i = 0; i < troopIds.length; ) {
            CityTroops[cityId][i] -= troopAmounts[i];
            unchecked {
                i++;
            }
        }
    }

    function checkTroops(
        uint cityId,
        uint[] memory troopIds,
        uint[] memory troopAmounts
    ) internal {
        for (uint i = 0; i < troopIds.length; ) {
            require(
                CityTroops[cityId][troopIds[i]] >= troopAmounts[i],
                "not enough"
            );
            unchecked {
                i++;
            }
        }
    }

    function squadsById(uint squadId) external view returns (Squad memory) {
        Squad memory squad = SquadsById[squadId];
        if (squad.ActiveAfter != 0 && block.timestamp > squad.ActiveAfter)
            squad.Active = true;
        return squad;
    }

    function squadsIdOnWorld(
        Coords memory coords
    ) external view returns (uint[] memory) {
        return SquadsIdOnWorld[coords.X][coords.Y].values();
    }

    function cityActiveSquads(
        uint cityId
    ) external view returns (uint[] memory) {
        return CityActiveSquads[cityId].values();
    }

    function hasDupes(uint[] memory arr) internal pure returns (bool) {
        bool hasDupe;
        uint temp;
        for (uint i = 0; i < arr.length; i++) {
            temp = arr[i];
            for (uint j = 0; j < arr.length; j++) {
                if ((j != i) && (temp == arr[j])) {
                    return true;
                }
            }
        }
        return false;
    }
}
