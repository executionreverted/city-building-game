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
    BaseCosts BaseCosts;
    uint[][] Cost;
}

struct BaseCosts {
    uint BaseGold;
    uint BaseGoldCoefficient1; 
    uint BaseGoldCoefficient2;
    uint BaseWood;
    uint BaseWoodCoefficient1; 
    uint BaseWoodCoefficient2;
    uint BaseStone;
    uint BaseStoneCoefficient1; 
    uint BaseStoneCoefficient2;
    uint BaseIron;
    uint BaseIronCoefficient1; 
    uint BaseIronCoefficient2;
    uint BaseFood;
    uint BaseFoodCoefficient1; 
    uint BaseFoodCoefficient2;
}