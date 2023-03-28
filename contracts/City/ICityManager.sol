// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

interface ICityManager {
    function upgradeBuilding(uint cityId, uint buildingId) external;

    function claimResource(uint cityId) external;

    function recruitTroops(uint cityId) external;

    function recruitPopulation(uint cityId) external;
}
