// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";

interface ICalculator {
    function calculateDistance(
        Coords memory c1,
        Coords memory c2
    ) external pure returns (uint distance);

    function timeBetweenTwoPoints(
        Coords memory c1,
        Coords memory c2
    ) external pure returns (uint time);
}
