// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {IERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import {City} from "./CityStructs.sol";

interface ICities is IERC721EnumerableUpgradeable {
    function mintCity(address to, City memory city) external;

    function city(uint256 id) external view returns (City memory);
}
