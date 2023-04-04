// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

struct Research {
    uint ID;
    uint TimeRequired;
    bool IsUnlocked;
    uint RequiredResearchId;
    uint MinResearchCenterLevel;
    uint[100] Cost;
}
