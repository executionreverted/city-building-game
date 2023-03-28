// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {IERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import {City} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {Coords} from "../World/WorldStructs.sol";

interface ICities is IERC721EnumerableUpgradeable {
    function mintCity(address to, City memory city) external;

    function city(uint256 id) external view returns (City memory);

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

    function ownerOf(uint cityId) external view returns (address);
}
