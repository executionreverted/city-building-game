// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {IERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import {City, Building} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {Coords} from "../World/WorldStructs.sol";

interface ICities is IERC721EnumerableUpgradeable {
    function mintCity(
        address to,
        Coords memory coords,
        Race race
    ) external returns (uint);
    

}
