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

struct Plot {
    int Climate;
    PlotContent Content;
    bool IsTaken;
    uint CityId;
    Coords Coords;
}

struct WorldAction {
    Coords Target;
    WorldActionTypes ActionType;
    uint ActionPayload;
}

enum WorldActionTypes {
    PLUNDER,
    INVADE,
    COLLECT,
    EXPLORE
}

struct PlotContent {
    PlotContentTypes Type;
    uint8 Tier; // tier
    uint Value1; // param type
    uint Value2; // min
    uint Value3; // max
}

enum PlotContentTypes {
    TAKEN,
    INHABITABLE,
    HABITABLE,
    RESOURCE,
    ENEMY,
    REWARD,
    CHEST
}
