// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {IBuilding} from "./IBuildings.sol";
import {Building} from "./CityStructs.sol";

contract Buildings is IBuilding, UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");

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
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Farms() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Mines() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Quarry() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    /* UTILITY BUILDINGS */
    function TownHall() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Warehouse() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Barracks() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Workshop() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Housing() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function ResearchCenter()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function DefenseTower()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function TradingPost()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Hatchery() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function WorldBossPortal()
        internal
        pure
        returns (Building memory _baseBuilding)
    {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function Walls() internal pure returns (Building memory _baseBuilding) {
        _baseBuilding.MaxTier = 5;
        _baseBuilding.Cost = generateCostArray();
        _baseBuilding.Cost[0] = 100;
        _baseBuilding.Cost[1] = 100;
        _baseBuilding.Cost[2] = 100;
        _baseBuilding.Cost[3] = 100;
        _baseBuilding.Cost[4] = 100;

        return _baseBuilding;
    }

    function generateCostArray()
        internal
        pure
        returns (uint[100] memory _return)
    {}
}
