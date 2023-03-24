// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";
import {ResourceCost} from "../Resources/ResourceStructs.sol";
import {Race} from "./CityEnums.sol";

struct City {
    Coords Coords;
    address Explorer;
    Race Race;
    bool Alive;
}

struct Building {
    uint BuildingType;
    uint Tier;
    uint MaxTier;
    ResourceCost Cost;
}
