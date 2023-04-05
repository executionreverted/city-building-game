// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";
import {Squad} from "./TroopsStructs.sol";

interface ITroopsManager {
    function cityActiveSquads(
        uint256 cityId
    ) external view returns (uint256[] memory);

    function cityTroops(
        uint256 cityId,
        uint256 troopId
    ) external view returns (uint256);

    function squadsById(uint256 squadId) external view returns (Squad memory);

    function squadsIdOnWorld(
        Coords memory coords
    ) external view returns (uint256[] memory);

    function squadsOnPlot(
        Coords memory coords
    ) external view returns (Squad[] memory);

    function troopsOfCity(
        uint256 cityId
    ) external view returns (uint8[] memory, uint256[] memory);

    function editSquad(Squad memory squad, bool destroy) external;
}
