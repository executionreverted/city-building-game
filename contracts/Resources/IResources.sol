// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Resource} from "./ResourceEnums.sol";

interface IResources {
    function cityResourceModifiers(
        uint256,
        Resource resource
    ) external view returns (int256);

    function cityResources(
        uint256,
        Resource resource
    ) external view returns (uint256);

    function lastClaims(
        uint256,
        Resource resource
    ) external view returns (uint256);

    function addResource(
        uint256 cityId,
        Resource resource,
        uint256 _amount
    ) external;

    function calculateHarvestableResource(
        uint256 cityId,
        Resource resource
    ) external view returns (uint256);

    function updateModifier(
        uint256 cityId,
        Resource resource,
        int256 value
    ) external returns (int256 _newModifier);

    function getRoundsSince(
        uint256 cityId,
        Resource resource
    ) external view returns (uint256 _rounds);


    function productionRate(
        uint256 cityId,
        Resource resource
    ) external view returns (uint256);

    function spendResource(
        uint256 cityId,
        Resource resource,
        uint256 amount
    ) external;

    function wrapResource(uint256 cityId, Resource resource) external;

    function unwrapResource(uint256 cityId, Resource resource) external;
}
