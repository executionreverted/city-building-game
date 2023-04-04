// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;


import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Race} from "../City/CityEnums.sol";
import {Coords} from "../City/CityStructs.sol";
import {IGameWorld} from "../World/IWorld.sol";
import {Resource} from "../Resources/ResourceEnums.sol";
import {IResources} from "../Resources/IResources.sol";
import {IBuilding} from "../City/IBuildings.sol";
import {ICalculator} from "../Core/ICalculator.sol";
import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";


contract ResearchManager is UpgradeableGameContract {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    ICityManager CityManager;
    IResources Resources;
    ICalculator Calculator;
    IGameWorld World;
    mapping(uint => bool[100]) CityResearchs;
    // movement stuff
}