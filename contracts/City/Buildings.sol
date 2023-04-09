// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {IBuilding} from "./IBuildings.sol";
import {Building} from "./CityStructs.sol";

contract Buildings is IBuilding, UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    uint constant MAX_RESOURCE_ID = 5;

    function initialize() external initializer {
        _initialize();
    }

    function allBuildings() external pure returns (Building[] memory) {
        Building[] memory _result = new Building[](15);
        for (uint i = 0; i < 15; i++) {
            _result[i] = buildingInfo(i);
        }

        return _result;
    }

    function buildingInfo(
        uint buildingId
    ) public pure override returns (Building memory) {
        if (buildingId == 0) return TownHall();
        if (buildingId == 1) return Forest();
        if (buildingId == 2) return Farms();
        if (buildingId == 3) return Mines();
        if (buildingId == 4) return Quarry();
        if (buildingId == 5) return Warehouse();
        if (buildingId == 6) return Barracks();
        if (buildingId == 7) return Workshop();
        if (buildingId == 8) return Housing();
        if (buildingId == 9) return ResearchCenter();
        if (buildingId == 10) return DefenseTower();
        if (buildingId == 11) return TradingPost();
        if (buildingId == 12) return Hatchery();
        if (buildingId == 13) return WorldBossPortal();
        if (buildingId == 14) return Walls();
        revert("not implemented");
    }

    function calculateValue(
        uint tier,
        uint base,
        uint coeff,
        uint coeffPerc
    ) internal pure returns (uint) {
        // base point * ( cofficient1 * coefficient perc * (level * level-1))

        return base + (((coeff * (coeffPerc)) / 100) * (tier * tier - 1));
    }

    /* [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */

    /* PRODUCTION BUILDING */

    function Forest() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Farms() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Mines() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Quarry() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    /* UTILITY BUILDINGS */
    function TownHall() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Warehouse() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Barracks() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Workshop() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Housing() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function ResearchCenter()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function DefenseTower()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function TradingPost()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Hatchery() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function WorldBossPortal()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function Walls() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.UtilityValues = new uint[](_baseBuilding.MaxTier);
        _baseBuilding.UtilityValues[0] = 5; // means at tier 1, it will have value of 5% for whatever it does
        _baseBuilding.UtilityValues[1] = 7;
        _baseBuilding.UtilityValues[2] = 9;
        _baseBuilding.UtilityValues[3] = 11;
        _baseBuilding.UtilityValues[4] = 15;
        _baseBuilding.RequiredResearchID = 1;

        // building time values
        _baseBuilding.BaseTime = 13;
        _baseBuilding.Coefficient = 10;
        _baseBuilding.CoefficientRatio = 70; // 0,7

        // building resource cost values
        _baseBuilding.BaseCosts.BaseGold = 20;
        _baseBuilding.BaseCosts.BaseGoldCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseGoldCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseWood = 15;
        _baseBuilding.BaseCosts.BaseWoodCoefficient1 = 50;
        _baseBuilding.BaseCosts.BaseWoodCoefficient2 = 40;
        _baseBuilding.BaseCosts.BaseStone = 20;
        _baseBuilding.BaseCosts.BaseStoneCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseStoneCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseIron = 20;
        _baseBuilding.BaseCosts.BaseIronCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseIronCoefficient2 = 60;
        _baseBuilding.BaseCosts.BaseFood = 20;
        _baseBuilding.BaseCosts.BaseFoodCoefficient1 = 55;
        _baseBuilding.BaseCosts.BaseFoodCoefficient2 = 60;

        _baseBuilding = enterResourceCost(_baseBuilding);

        _baseBuilding = enterTimeCost(_baseBuilding);

        return _baseBuilding;
    }

    function generateCostArray(
        uint maxTier
    ) internal pure returns (uint[][] memory) {
        uint[][] memory _tierArray = new uint[][](maxTier);
        for (uint i = 0; i < _tierArray.length; i++) {
            _tierArray[i] = new uint[](MAX_RESOURCE_ID);
        }

        return _tierArray;
    }

    /*    function generateTimeArray(
        uint[] memory timeRequiredByTiers
    ) internal pure returns (uint[] memory) {
        uint[] memory _return = new uint[](timeRequiredByTiers.length);
        for (uint i = 0; i < timeRequiredByTiers.length; ) {
            _return[i] = timeRequiredByTiers[i];
            unchecked {
                i++;
            }
        }
        return _return;
    } */

    function enterResourceCost(
        Building memory _baseBuilding
    ) internal pure returns (Building memory) {
        uint len = _baseBuilding.MaxTier + 1;
        _baseBuilding.Cost = generateCostArray(len);
        for (uint i = 1; i < len; ) {
            _baseBuilding.Cost[i][0] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseGold,
                _baseBuilding.BaseCosts.BaseGoldCoefficient1,
                _baseBuilding.BaseCosts.BaseGoldCoefficient2
            );
            _baseBuilding.Cost[i][1] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseWood,
                _baseBuilding.BaseCosts.BaseWoodCoefficient1,
                _baseBuilding.BaseCosts.BaseWoodCoefficient2
            );
            _baseBuilding.Cost[i][2] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseStone,
                _baseBuilding.BaseCosts.BaseStoneCoefficient1,
                _baseBuilding.BaseCosts.BaseStoneCoefficient2
            );
            _baseBuilding.Cost[i][3] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseIron,
                _baseBuilding.BaseCosts.BaseIronCoefficient1,
                _baseBuilding.BaseCosts.BaseIronCoefficient2
            );
            _baseBuilding.Cost[i][4] = calculateValue(
                i,
                _baseBuilding.BaseCosts.BaseFood,
                _baseBuilding.BaseCosts.BaseFoodCoefficient1,
                _baseBuilding.BaseCosts.BaseFoodCoefficient2
            );
            unchecked {
                i++;
            }
        }
        return _baseBuilding;
    }

    function enterTimeCost(
        Building memory _baseBuilding
    ) internal pure returns (Building memory) {
        // uint len = _baseBuilding.MaxTier + 1;
        uint[] memory timeRequired = new uint[](_baseBuilding.MaxTier);
        for (uint i = 1; i <= timeRequired.length; ) {
            timeRequired[i - 1] =
                calculateValue(
                    i,
                    _baseBuilding.BaseTime,
                    _baseBuilding.Coefficient,
                    _baseBuilding.CoefficientRatio
                ) *
                1 minutes;
            unchecked {
                i++;
            }
        }
        _baseBuilding.UpgradeTime = timeRequired;
        return _baseBuilding;
    }
}
