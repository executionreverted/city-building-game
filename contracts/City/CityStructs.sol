// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";
import {Race} from "./CityEnums.sol";

struct City {
    Coords Coords;
    address Explorer;
    Race Race;
    bool Alive;
    uint CreationDate;
    uint Population;
}

struct Building {
    uint[] UpgradeTime;
    uint Tier;
    uint MaxTier;
    uint[100] Cost;
}
