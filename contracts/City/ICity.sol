// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {IERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import {City} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {Coords} from "../World/WorldStructs.sol";

interface ICities is IERC721EnumerableUpgradeable {
    function mintCity(address to, City memory city) external;

    function city(uint256 id) external view returns (City memory);

    function updateCityCoords(uint cityId, Coords memory _param) external;

    function updateCityRace(uint cityId, Race _param) external;

    function updateCityAlive(uint cityId, bool _param) external;

    function updateCityPopulation(uint cityId, uint _param) external;
}
