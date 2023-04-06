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
import {ITroopCommands} from "./ITroopCommands.sol";
import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
// import "hardhat/console.sol";
import {ErrorNull, ErrorAlreadyGoingOn, ErrorExceeds, ErrorAssertion, ErrorBadTiming, ErrorUnauthorized} from "../Utils/Errors.sol";

contract TroopsManager is UpgradeableGameContract {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    event Recruitment(uint indexed cityId, uint indexed troopId, uint amount);
    event SquadRemoved(uint indexed troopId);
    event SquadMovement(
        uint indexed cityId,
        uint indexed squadId,
        Coords from,
        Coords to
    );

    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    ICityManager CityManager;
    IResources Resources;
    ITroops Troops;
    ICalculator Calculator;
    IGameWorld World;
    ITroopCommands TroopCommands;
    uint8 constant MAX_MATERIAL_ID = 5;
    uint8 constant FOOD_PER_MINUTE = 5;
    uint8 constant MAX_SQUADS_ON_PLOT = 10;
    uint8 constant BARRACKS_ID = 6;

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

    function setTroopCommands(address _troopcmd) external onlyOwner {
        TroopCommands = ITroopCommands(_troopcmd);
    }

    modifier onlyCityOwner(uint cityId) {
        if (Cities.ownerOf(cityId) != msg.sender) {
            revert ErrorUnauthorized(msg.sender);
        }
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
    ) external view returns (uint8[] memory, uint[] memory) {
        Race race = CityManager.race(cityId);
        // race stuff... determine ids of troops by race
        uint i;
        uint8 startTroop = 0 * uint8(race);
        uint8 endTroop = 1 * uint8(race);

        uint8[] memory troopIds = new uint8[](endTroop - startTroop);
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
        if (amount == 0) {
            revert ErrorNull(amount);
        }
        // check requirements, burn and set resource modifier
        Troop memory _troop = Troops.troopInfo(troopId);
        // int _modifier;
        uint _cityPopulation = CityManager.cityPopulation(cityId);
        uint _population;

        // MinBarracksLevel
        uint barracksLevel = CityManager.buildingLevel(cityId, BARRACKS_ID);
        if (barracksLevel < _troop.Cost.MinBarracksLevel) {
            revert ErrorAssertion(
                barracksLevel < _troop.Cost.MinBarracksLevel,
                false
            );
        }
        // check population
        uint[] memory _costs = new uint[](MAX_MATERIAL_ID);
        for (uint i = 0; i < MAX_MATERIAL_ID; i++) {
            _costs[i] = _troop.Cost.ResourceCost[i] * amount;
        }

        Resources.spendResources(cityId, _costs);
        // _modifier += _troop.Cost.ResourceModifier * int(amount);
        // Resources.updateModifier(cityId, Resource(i), _modifier);

        _population += _troop.Population * amount;

        if (_population > _cityPopulation) {
            revert ErrorExceeds(_cityPopulation, _population);
        }

        CityManager.updateCityPopulation(cityId, _cityPopulation - _population);
        CityTroops[cityId][troopId] += amount;
        emit Recruitment(cityId, troopId, amount);
    }

    function recruitTroops(
        uint cityId,
        uint8[] calldata troopIds,
        uint[] calldata amounts
    ) external onlyCityOwner(cityId) {
        if (troopIds.length != amounts.length) {
            revert ErrorAssertion(troopIds.length == amounts.length, false);
        }
        uint _population;
        uint[] memory _costs = new uint[](MAX_MATERIAL_ID);
        for (uint i = 0; i < amounts.length; ) {
            uint amount = amounts[i];
            uint troopId = troopIds[i];
            if (amount == 0) {
                revert ErrorNull(amount);
            }
            // check requirements, burn and set resource modifier
            Troop memory _troop = Troops.troopInfo(troopId);
            // int _modifier;
            // check population

            for (uint y = 0; y < MAX_MATERIAL_ID; y++) {
                _costs[y] += _troop.Cost.ResourceCost[y] * amount;
            }

            _population += _troop.Population * amount;
            CityTroops[cityId][troopId] += amount;
            emit Recruitment(cityId, troopId, amount);
            unchecked {
                i++;
            }
        }

        uint _cityPopulation = CityManager.cityPopulation(cityId);
        if (_cityPopulation < _population) {
            revert ErrorExceeds(_cityPopulation, _population);
        }
        Resources.spendResources(cityId, _costs);
        CityManager.updateCityPopulation(cityId, _cityPopulation - _population);
    }

    function _releaseTroop(
        uint cityId,
        uint troopId,
        uint amount
    ) internal returns (uint) {
        if (amount == 0) {
            revert ErrorNull(amount);
        }
        if (CityTroops[cityId][troopId] < amount) {
            revert ErrorExceeds(CityTroops[cityId][troopId], amount);
        }
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
        if (troopIds.length != amounts.length) {
            revert ErrorAssertion(troopIds.length == amounts.length, false);
        }
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
        uint8[] memory troopIds,
        uint[] memory troopAmounts,
        Purpose purpose
    ) external onlyCityOwner(cityId) {
        if (hasDupes(troopIds)) {
            revert ErrorAssertion(true, false);
        }

        if (troopIds.length != troopAmounts.length) {
            revert ErrorAssertion(
                troopIds.length == troopAmounts.length,
                false
            );
        }
        uint squadsOnThisPlot = SquadsIdOnWorld[coords.X][coords.Y].length();
        if (squadsOnThisPlot >= MAX_SQUADS_ON_PLOT) {
            revert ErrorExceeds(squadsOnThisPlot, MAX_SQUADS_ON_PLOT);
        }
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
            (FOOD_PER_MINUTE) +
                ((timeBetweenCoords / 1 minutes) * FOOD_PER_MINUTE),
            Resource.FOOD
        );

        Squad memory newSquad = Squad({
            ID: squadNonces,
            TroopIds: troopIds,
            TroopAmounts: troopAmounts,
            Position: coords,
            Purpose: purpose,
            ActiveAfter: block.timestamp + timeBetweenCoords,
            Active: false,
            ControlledBy: cityId
        });

        SquadsById[squadNonces] = newSquad;
        SquadsIdOnWorld[coords.X][coords.Y].add(squadNonces);
        CityActiveSquads[cityId].add(squadNonces);
        emit SquadMovement(cityId, squadNonces, coords, coords);
        squadNonces++;
    }

    function callSquadBack(
        uint cityId,
        uint squadId
    ) external onlyCityOwner(cityId) {
        if (!CityActiveSquads[cityId].contains(squadId)) {
            revert ErrorNull(0);
        }
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
        emit SquadRemoved(squadId);
    }

    function repositionSquad(
        uint cityId,
        uint squadId,
        Coords memory newCoords
    ) external onlyCityOwner(cityId) {
        Squad memory squad = SquadsById[squadId];

        if (!CityActiveSquads[cityId].contains(squadId)) {
            revert ErrorNull(0);
        }
        if (block.timestamp < squad.ActiveAfter) {
            revert ErrorBadTiming(block.timestamp, squad.ActiveAfter);
        }

        uint squadsInThisPlot = SquadsIdOnWorld[newCoords.X][newCoords.Y]
            .length();
        if (squadsInThisPlot >= MAX_SQUADS_ON_PLOT) {
            revert ErrorExceeds(squadsInThisPlot, MAX_SQUADS_ON_PLOT);
        }
        uint timeBetweenCoords = Calculator.timeBetweenTwoPoints(
            squad.Position,
            newCoords
        );

        // burn food
        Resources.spendResource(
            cityId,
            (timeBetweenCoords / 1 minutes) * FOOD_PER_MINUTE,
            Resource.FOOD
        );
        emit SquadMovement(cityId, squadNonces, squad.Position, newCoords);
        SquadsIdOnWorld[squad.Position.X][squad.Position.Y].remove(squadId);
        SquadsById[squadId].Position = newCoords;
        SquadsIdOnWorld[newCoords.X][newCoords.Y].add(squadId);
        SquadsById[squadId].ActiveAfter = block.timestamp + timeBetweenCoords;
        // SquadsById[squadId].ActiveAfter = SquadsById[squadId].ActiveAfter + timeBetweenCoords;
    }

    function editSquad(Squad memory squad, bool destroy) external {
        if(msg.sender != address(TroopCommands)) {
            revert ErrorUnauthorized(msg.sender);
        }
        if (destroy) {
            // console.log("destroy");
            // console.log(destroy, squad.ID);
            SquadsIdOnWorld[squad.Position.X][squad.Position.Y].remove(
                squad.ID
            );
            CityActiveSquads[squad.ControlledBy].remove(squad.ID);
            SquadsById[squad.ID].Active = false;
            SquadsById[squad.ID].ActiveAfter = 0;
            // delete SquadsById[squad.ID];
            emit SquadRemoved(squad.ID);
        } else {
            SquadsById[squad.ID] = squad;
        }
    }

    function changePurpose(
        uint cityId,
        uint squadId,
        Purpose newPurpose
    ) external onlyCityOwner(cityId) {
        require(SquadsById[squadId].ControlledBy == cityId, "???");
        SquadsById[squadId].Purpose = newPurpose;
    }

    function reduceTroopsInTown(
        uint cityId,
        uint8[] memory troopIds,
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
        uint8[] memory troopIds,
        uint[] memory troopAmounts
    ) internal view {
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

    function squadsOnPlot(
        Coords memory coords
    ) public view returns (Squad[] memory) {
        uint[] memory squadIds = SquadsIdOnWorld[coords.X][coords.Y].values();
        Squad[] memory result = new Squad[](squadIds.length);

        for (uint i = 0; i < squadIds.length; i++) {
            result[i] = SquadsById[squadIds[i]];
        }
        return result;
    }

    function cityActiveSquads(
        uint cityId
    ) external view returns (uint[] memory) {
        return CityActiveSquads[cityId].values();
    }

    function hasDupes(uint8[] memory arr) internal pure returns (bool) {
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
