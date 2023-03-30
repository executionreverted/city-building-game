// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

struct Troop {
    uint Atk;
    uint SiegeAtk;
    uint Def;
    uint SiegeDef;
    uint Hp;
    uint Capacity;
    TroopCost Cost;
    uint Population;
    uint ResourceModifier;
}

struct TroopCost {
    uint[100] ResourceCost;
}
