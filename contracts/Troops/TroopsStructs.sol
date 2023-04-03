// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";

enum Purpose {
    SCOUT,
    DEFEND,
    ATTACK
}

struct Troop {
    uint Atk;
    uint SiegeAtk;
    uint Def;
    uint SiegeDef;
    uint Hp;
    uint Capacity;
    TroopCost Cost;
    uint Population;
}

struct TroopCost {
    uint[100] ResourceCost;
    int ResourceModifier;
}

struct Squad {
    uint[] troopIds;
    uint[] troopAmounts;
    Coords position;
    Purpose purpose;
    uint activeAfter;
    bool active;
}
