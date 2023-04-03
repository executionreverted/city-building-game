// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";

interface ICalculator {
    function armyPower(
        uint256 cityId
    )
        external
        view
        returns (
            uint256 Atk,
            uint256 SiegeAtk,
            uint256 Def,
            uint256 SiegeDef,
            uint256 Hp,
            uint256 Capacity
        );

    function attackerCasualties(
        uint256 atkArmyPower,
        uint256 defArmyPower,
        bool atkHasWon,
        bool draw
    ) external pure returns (uint256);

    function attackerVictoryChance(
        uint256 atkArmyPower,
        uint256 defArmyPower
    ) external pure returns (uint256);

    function calculateDistance(
        Coords memory c1,
        Coords memory c2
    ) external pure returns (uint256 distance);

    function defenderCasualties(
        uint256 atkArmyPower,
        uint256 defArmyPower,
        bool atkHasWon,
        bool draw
    ) external view returns (uint256);

    function defenderVictoryChance(
        uint256 atkArmyPower,
        uint256 defArmyPower
    ) external pure returns (uint256);

    function plunderAmountPercentage(
        uint256 atkArmyPower,
        uint256 defArmyPower
    ) external view returns (uint256);

    function plunderededResources() external view returns (uint256);

    function timeBetweenTwoPoints(
        Coords memory a,
        Coords memory b
    ) external pure returns (uint256);
}
