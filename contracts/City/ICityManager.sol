import {City, Race} from "./CityStructs.sol";
import {Coords} from "../World/WorldStructs.sol";
import {Building} from "../City/CityStructs.sol";
// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

interface ICityManager {
    function upgradeBuilding(
        uint cityId,
        uint buildingId
    ) external returns (bool);

    function recruitPopulation(uint cityId) external;

    function setCity(uint id, City memory city) external;

    function city(uint cityId) external view returns (City memory);

    function updateCityCoords(
        uint cityId,
        Coords memory _param
    ) external returns (bool);

    function updateCityRace(uint cityId, Race _param) external returns (bool);

    function updateCityAlive(uint cityId, bool _param) external returns (bool);

    function updateCityPopulation(
        uint cityId,
        uint _newPopulation
    ) external returns (bool);

    function cityPopulation(uint cityId) external view returns (uint);

    function race(uint cityId) external view returns (Race);

    function mintTime(uint cityId) external view returns (uint);

    function buildingLevel(
        uint cityId,
        uint buildingId
    ) external view returns (uint);

    function buildingLevels(
        uint cityId
    ) external view returns (Building[] memory);
}
