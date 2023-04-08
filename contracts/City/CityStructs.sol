// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";
import {Race} from "./CityEnums.sol";

struct City {
    Coords Coords;
    Race Race;
    address Explorer;
    uint CreationDate;
    uint Population;
    bool Alive;
}

struct Building {
    uint Tier;
    uint MaxTier;
    uint BaseTime;
    uint Coefficient;
    uint CoefficientRatio;
    uint RequiredResearchID;
    uint[] UpgradeTime;
    uint[] UtilityValues;
    uint[100] Cost;
}
