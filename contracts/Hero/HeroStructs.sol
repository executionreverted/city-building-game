// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

struct Hero {
    uint Level;
    uint XP;
    address Operator;
    uint[] Cities;
    Perk[5] Perks;
}

struct Perk {
    uint ID;
    uint[] ActionValues;
    uint[] ActionValue2;
    PerkActionType[] Action;
}

enum PerkActionType {
    BUFF,
    DEBUFF
}
