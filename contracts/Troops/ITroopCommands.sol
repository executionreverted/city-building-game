// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";

interface ITroopCommands {
    function attack(
        uint256 squadId,
        uint8 target,
        uint256 targetSquadId
    ) external;

    function checkIfTargetInRange(
        Coords memory c1,
        Coords memory c2
    ) external view returns (bool);
}
