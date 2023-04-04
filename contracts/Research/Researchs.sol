// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {Research} from "./ResearchStructs.sol";

contract Researchs is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");

    function initialize() external initializer {
        _initialize();
    }

    function allResearchs() external pure returns (Research[] memory) {
        Research[] memory _result = new Research[](15);
        for (uint i = 0; i < 15; i++) {
            _result[i] = researchInfo(i);
        }

        return _result;
    }

    function researchInfo(
        uint researchId
    ) public pure returns (Research memory) {
        if (researchId == 1) return Research1();
        revert("not implemented");
    }

    function Research1() internal pure returns (Research memory _baseResearch) {
        _baseResearch.ID = 1; // no requirements.
        _baseResearch.RequiredResearchId = 0; // no requirements.

        // if its default unlocked, uncomment that line.
        // _baseResearch.IsUnlocked = true; // no requirements.

        _baseResearch.TimeRequired = 1 hours;
        _baseResearch.MinResearchCenterLevel = 1;

        _baseResearch.Cost = generateCostArray();
        _baseResearch.Cost[0] = 100;
        _baseResearch.Cost[1] = 100;
        _baseResearch.Cost[2] = 100;
        _baseResearch.Cost[3] = 100;
        _baseResearch.Cost[4] = 100;

        return _baseResearch;
    }

    /* [
    GOLD, 0
    WOOD, 1
    STONE,2
    IRON, 3
    FOOD  4
    ] */

    /* PRODUCTION BUILDING */

    function generateCostArray()
        internal
        pure
        returns (uint[100] memory _return)
    {}
}
