// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Resource} from "../Resources/ResourceEnums.sol";
import {IResources} from "../Resources/IResources.sol";
import {IBuilding} from "../City/IBuilding.sol";

contract Troops is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    ICityManager CityManager;
    IResources Resources;

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setBuilding(address _builds) external onlyOwner {
        Buildings = IBuilding(_builds);
    }

    function initialize(
        address _cities,
        address _building,
        address _cityManager,
        address _resources
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        Buildings = IBuilding(_building);
        CityManager = ICityManager(_cityManager);
        Resources = IResources(_resources);
    }

    function recruitTroop(uint cityId) external {}
}
