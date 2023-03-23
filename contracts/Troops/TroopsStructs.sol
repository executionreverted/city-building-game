// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {ResourceCost} from "../Resources/ResourceStructs.sol";

struct Troop {
    uint Atk;
    uint SiegeAtk;
    uint Def;
    uint SiegeDef;
    uint Hp;
    uint Capacity;
    TroopCost Cost;
}

struct TroopCost {
    ResourceCost ResourceCost;
}
