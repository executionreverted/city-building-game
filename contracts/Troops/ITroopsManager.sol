// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

interface ITroopsManager {
    function cityTroops(
        uint256 cityId,
        uint256 troopId
    ) external view returns (uint256);

    function troopsOfCity(
        uint256 cityId
    ) external view returns (uint256[] memory, uint256[] memory);
}
