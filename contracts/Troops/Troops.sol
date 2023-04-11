// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {Troop} from "./TroopsStructs.sol";

contract Troops is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");

    function initialize() external initializer {
        _initialize();
    }

    function troopInfo(uint troopId) public pure returns (Troop memory) {
        if (troopId == 0) return Soldier();
        revert("not implemented");
    }

    /* [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */

    /* PRODUCTION troop */

    function armyPower(
        uint8[] memory troopIds,
        uint[] memory amounts
    )
        external
        pure
        returns (
            uint Atk,
            uint SiegeAtk,
            uint Def,
            uint SiegeDef,
            uint Hp,
            uint Capacity
        )
    {
        require(troopIds.length == amounts.length, "mismatch");
        for (uint i = 0; i < troopIds.length; i++) {
            Troop memory _troop = troopInfo(troopIds[i]);
            Atk += _troop.Atk * amounts[i];
            SiegeAtk += _troop.SiegeAtk * amounts[i];
            Def += _troop.Def * amounts[i];
            SiegeDef += _troop.SiegeDef * amounts[i];
            Hp += _troop.Hp * amounts[i];
            Capacity += _troop.Capacity * amounts[i];
        }
    }

    function Soldier() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 10;
        _baseTroop.SiegeAtk = 10;
        _baseTroop.Def = 10;
        _baseTroop.SiegeDef = 10;
        _baseTroop.Hp = 10;
        _baseTroop.Capacity = 10;
        _baseTroop.Cost.FoodCostMultiplier = 1;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 100; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 100; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 100; // STONE
        _baseTroop.Cost.ResourceCost[3] = 100; // IRON
        _baseTroop.Cost.ResourceCost[4] = 100; // FOOD
        _baseTroop.Cost.MinBarracksLevel = 1;
        _baseTroop.Population = 1;

        return _baseTroop;
    }

    function generateCostArray()
        internal
        pure
        returns (uint[100] memory _return)
    {}
}
