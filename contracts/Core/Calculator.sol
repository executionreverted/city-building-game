// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {ICalculator} from "./ICalculator.sol";
import {Coords} from "../World/WorldStructs.sol";

contract Calculator is ICalculator {
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
