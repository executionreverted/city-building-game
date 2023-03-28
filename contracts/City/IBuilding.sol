import {Building} from "./CityStructs.sol";
// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

interface IBuilding {
    function buildingInfo(
        uint buildingId
    ) external view returns (Building memory);
}
