// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICities} from "../City/ICity.sol";
import {Resource} from "./ResourceEnums.sol";
import {IBuilding} from "../City/IBuilding.sol";

contract Resources is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    IBuilding Building;
    /* 
    [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */
    uint[5] BaseProductions;
    mapping(uint => uint[10]) public LastClaims;
    mapping(uint => uint[10]) public CityResources;

    function initialize(
        address _cities,
        address _buildings
    ) external initializer {
        Cities = ICities(_cities);
        Building = IBuilding(_buildings);
    }

    function setBaseProductions() external onlyOwner {
        BaseProductions[0] = 100;
        BaseProductions[1] = 100;
        BaseProductions[2] = 100;
        BaseProductions[3] = 100;
        BaseProductions[4] = 100;
    }

    function claimResource(uint cityId, Resource resource) external {
        address _owner = Cities.ownerOf(cityId);
        require(_owner == msg.sender, "unauthorized");
        uint amount = calculateHarvestableResource(cityId, resource);

        if (amount > 0) {
            CityResources[cityId][uint(resource)] += amount;
        } else revert("nothing to claim");
    }

    function calculateHarvestableResource(
        uint cityId,
        Resource resource
    ) public view returns (uint) {
        // check building lvl, check plot info

        return 0;
    }
}
