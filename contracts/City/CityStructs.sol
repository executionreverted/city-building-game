// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {ResourceCost} from "../Resources/ResourceStructs.sol";
import {Race} from "./CityEnums.sol";

struct City {
    int[2] Coords;
    address Explorer;
    Race Race;
}

struct Building {
    uint BuildingType;
    uint Tier;
    uint MaxTier;
    ResourceCost Cost;
}
