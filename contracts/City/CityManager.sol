// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {Building} from "./CityStructs.sol";
import {City} from "./CityStructs.sol";
import {ICities} from "./ICity.sol";
import {IBuilding} from "../City/IBuilding.sol";
import {ICityManager} from "./ICityManager.sol";

contract CityManager is ICityManager, UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Buildings;
    mapping(uint => uint) PopulationClaimDates;

    function initialize() external initializer {
        _initialize();
    }

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setBuilding(address _builds) external onlyOwner {
        Buildings = IBuilding(_builds);
    }

    modifier onlyCityOwner(uint cityId) {
        require(Cities.ownerOf(cityId) == msg.sender, "unauth");
        _;
    }

    function upgradeBuilding(
        uint cityId,
        uint resourceId
    ) external override onlyCityOwner(cityId) {}

    function claimResource(
        uint cityId
    ) external override onlyCityOwner(cityId) {}

    function recruitTroops(
        uint cityId
    ) external override onlyCityOwner(cityId) {}

    function recruitPopulation(
        uint cityId
    ) external override onlyCityOwner(cityId) {
        uint _recruitable;
        require(PopulationClaimDates[cityId] < block.timestamp, "early");
        City memory _city = Cities.city(cityId);
        // fetch townhall lvl & housing, give bonus daily population, 4 townhall & 7 housing
        Building memory _townhall = Buildings.buildingInfo(4);
        require(_city.Population <= _townhall.Tier * 50, "exceeds");
        Building memory _housing = Buildings.buildingInfo(7);

        _recruitable += _townhall.Tier;
        _recruitable += _housing.Tier * 2;
        PopulationClaimDates[cityId] = block.timestamp + 1 days;
        Cities.updateCityPopulation(
            cityId,
            Cities.cityPopulation(cityId) + _recruitable
        );
    }
}
