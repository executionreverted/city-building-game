// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";
import {Squad, Purpose, Target} from "./TroopsStructs.sol";
import {ITroopsManager} from "./ITroopsManager.sol";
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICities} from "../City/ICities.sol";
import {ICalculator} from "../Core/ICalculator.sol";

contract TroopCommands is UpgradeableGameContract {
    ITroopsManager TroopsManager;
    ICities Cities;
    ICalculator Calculator;

    uint constant ACTION_RANGE = 3;

    function initialize(
        address _troopsManager,
        address _cities,
        address _calc
    ) external initializer {
        _initialize();
        TroopsManager = ITroopsManager(_troopsManager);
        Cities = ICities(_cities);
        Calculator = ICalculator(_calc);
    }

    function attack(uint squadId, Target target, uint targetSquadId) external {
        Squad memory squad = TroopsManager.squadsById(squadId);
        checkIfSquadOwned(squad);

        // implement if target == enemy squad

        // implement if target == enemy city in this plot
        // check if city exists in plot
        // calculate battle functions

        // implement if target == plot content in this plot
        // npc fight, roll random enemy using plot seed
    }

    function protect() external {}

    function checkIfTargetInRange(
        Coords memory c1,
        Coords memory c2
    ) public returns (bool) {
        uint dist = Calculator.calculateDistance(c1, c2);
        return dist < ACTION_RANGE;
    }

    function checkIfSquadOwned(
        Squad memory squad
    ) internal view returns (bool) {
        require(Cities.ownerOf(squad.ControlledBy) == msg.sender, "not owned");
        return true;
    }
}
