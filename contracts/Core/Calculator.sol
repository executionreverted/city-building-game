// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {ICalculator} from "./ICalculator.sol";
import {Coords} from "../World/WorldStructs.sol";
import {ITroops} from "../Troops/ITroops.sol";
import {ITroopsManager} from "../Troops/ITroopsManager.sol";
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";

contract Calculator is ICalculator, UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ITroops Troops;
    ITroopsManager TroopsManager;

    function initialize(
        address _troopCodex,
        address _troopManager
    ) external initializer {
        _initialize();
        Troops = ITroops(_troopCodex);
        TroopsManager = ITroopsManager(_troopManager);
    }

    /*     
        Army power = (Number of soldiers * Attack power * Defense power * Health) * Morale bonus
    */
    function armyPower(
        uint cityId
    )
        external
        view
        returns (
            uint Atk,
            uint SiegeAtk,
            uint Def,
            uint SiegeDef,
            uint Hp,
            uint Capacity
        )
    {
        (uint[] memory troops, uint[] memory amounts) = TroopsManager
            .troopsOfCity(cityId);
        return Troops.armyPower(troops, amounts);
    }

    /* 
        Attacker victory chance = (Attacker army power / Defender army power) * 100
        Defender victory chance = 100 - Attacker victory chance
        Plunder amount percentage = Attacker army power / Defender army power
        Plundered resources = (Percentage of plundered resources * Defender's total resources) * Plunder efficiency factor
        Attacker casualties = (Attacker army power / Defender army power) * Defender casualties
        Defender casualties = (Defender army power / Attacker army power) * Attacker casualties */
    function calculateDistance(
        Coords memory c1,
        Coords memory c2
    ) public pure returns (uint distance) {
        distance = uint(sqrt((c2.X - c1.X) ** 2 + (c2.Y - c1.Y) ** 2));
    }

    function timeBetweenTwoPoints(
        Coords memory a,
        Coords memory b
    ) public pure returns (uint) {
        return calculateDistance(a, b) * 2 minutes;
    }

    function _calculateDistance(
        int x1,
        int y1,
        int x2,
        int y2
    ) internal pure returns (uint distance) {
        distance = uint(sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2));
    }

    function sqrt(int x) public pure returns (int y) {
        int z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
