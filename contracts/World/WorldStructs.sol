// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

struct World {
    int LastXPositive;
    int LastXNegative;
    int LastYPositive;
    int LastYNegative;
}

struct Coords {
    int X;
    int Y;
}