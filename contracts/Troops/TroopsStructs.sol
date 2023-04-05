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
    uint Population;
    TroopCost Cost;
}

struct TroopCost {
    uint[100] ResourceCost;
    uint MinBarracksLevel;
}

struct Squad {
    uint8[] TroopIds;
    uint ID;
    uint ControlledBy;
    uint ActiveAfter;
    uint[] TroopAmounts;
    bool Active;
    Coords Position;
    Purpose Purpose;
}

enum Target {
    SQUAD,
    CITY,
    PLOT_CONTENT
}
