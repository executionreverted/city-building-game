// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {Troop} from "./TroopsStructs.sol";

contract Troops is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");

    function initialize() external initializer {
        _initialize();
    }

    function troopInfo(uint troopId) external pure returns (Troop memory) {
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

    function Soldier() internal pure returns (Troop memory _baseTroop) {
        _baseTroop.Atk = 10;
        _baseTroop.SiegeAtk = 10;
        _baseTroop.Def = 10;
        _baseTroop.SiegeDef = 10;
        _baseTroop.Hp = 10;
        _baseTroop.Capacity = 10;
        _baseTroop.Cost.ResourceCost = generateCostArray();
        _baseTroop.Cost.ResourceCost[0] = 100; // GOLD,
        _baseTroop.Cost.ResourceCost[1] = 100; //  WOOD
        _baseTroop.Cost.ResourceCost[2] = 100; // STONE
        _baseTroop.Cost.ResourceCost[3] = 100; // IRON
        _baseTroop.Cost.ResourceCost[4] = 100; // FOOD
        _baseTroop.Cost.ResourceModifier = -1;
        _baseTroop.Population = 10;

        return _baseTroop;
    }

    function generateCostArray()
        internal
        pure
        returns (uint[100] memory _return)
    {}
}
