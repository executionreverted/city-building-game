// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Troop} from "./TroopsStructs.sol";

interface ITroops {
    function troopInfo(uint256 troopId) external pure returns (Troop memory);

    function armyPower(
        uint[] memory troopIds,
        uint[] memory amounts
    )
        external
        view
        returns (
            uint Atk,
            uint SiegeAtk,
            uint Def,
            uint SiegeDef,
            uint Hp,
            uint Capacity
        );
}
