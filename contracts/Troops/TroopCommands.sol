// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Coords} from "../World/WorldStructs.sol";
import {Squad, Purpose, Target} from "./TroopsStructs.sol";
import {ITroopsManager} from "./ITroopsManager.sol";
import {ITroops} from "./ITroops.sol";
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICities} from "../City/ICities.sol";
import {ICalculator} from "../Core/ICalculator.sol";
import {IRNG} from "../Utils/IRNG.sol";
// import "hardhat/console.sol";
import {ErrorNull, ErrorAlreadyGoingOn, ErrorExceeds, ErrorAssertion, ErrorBadTiming, ErrorUnauthorized} from "../Utils/Errors.sol";

contract TroopCommands is UpgradeableGameContract {
    event PlotFight(
        uint indexed attackerSquadId,
        uint indexed victimSquadId,
        uint result,
        uint attackerCasualties,
        uint defenderCasualties
    );

    ITroopsManager TroopsManager;
    ICities Cities;
    ICalculator Calculator;
    ITroops Troops;
    IRNG RNG;

    uint constant ACTION_RANGE = 3;

    function initialize(
        address _troopsManager,
        address _cities,
        address _calc,
        address _troops,
        address _rng
    ) external initializer {
        _initialize();
        TroopsManager = ITroopsManager(_troopsManager);
        Cities = ICities(_cities);
        Calculator = ICalculator(_calc);
        Troops = ITroops(_troops);
        RNG = IRNG(_rng);
    }

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setRNG(address _rng) external onlyOwner {
        RNG = IRNG(_rng);
    }

    function setCalculator(address _calc) external onlyOwner {
        Calculator = ICalculator(_calc);
    }

    function setTroops(address _troops) external onlyOwner {
        Troops = ITroops(_troops);
    }

    function setTroopManager(address _trmanager) external onlyOwner {
        TroopsManager = ITroopsManager(_trmanager);
    }

    // prevent atk to friendly squads
    function attack(uint squadId, Target target, uint targetSquadId) external {
        Squad memory squad = TroopsManager.squadsById(squadId);
        if (!squad.Active) {
            revert ErrorAssertion(squad.Active, true);
        }
        checkIfSquadOwned(squad);
        if (squad.Purpose != Purpose.ATTACK) {
            revert ErrorAssertion(squad.Purpose != Purpose.ATTACK, false);
        }
        // implement if target == enemy squad
        if (target == Target.SQUAD) {
            // attack stuff
            handleFieldBattle(squad, TroopsManager.squadsById(targetSquadId));
        }
        // implement if target == enemy city in this plot
        else if (target == Target.CITY) {
            // check if city exists in plot
            // calculate battle functions
        }
        // implement if target == plot content in this plot
        // npc fight, roll random enemy using plot seed
        else if (target == Target.PLOT_CONTENT) {} else {
            revert ErrorNull(0);
        }
    }

    function handleFieldBattle(
        Squad memory attacker,
        Squad memory victim
    ) internal {
        checkIfTargetInRange(attacker.Position, victim.Position);
        if (!victim.Active) {
            revert ErrorAssertion(victim.Active, true);
        }
        uint _result; // 0 ATK, 1 DEF, 2 DRAW
        (
            uint attackerArmyPower,
            uint defenderArmyPower
        ) = fieldWarArmyPowerFormula(attacker, victim);
        // calculate attacker stats

        // console.log("powers:");
        // console.log(attackerArmyPower);
        // console.log(defenderArmyPower);
        uint atkWinChance = Calculator.attackerVictoryChance(
            attackerArmyPower,
            defenderArmyPower
        );

        // console.log("atkWinChance");
        // console.log(atkWinChance);

        uint defWinChance = Calculator.defenderVictoryChance(
            attackerArmyPower,
            defenderArmyPower
        );
        // roll random
        // console.log("defWinChance");
        // console.log(defWinChance);

        uint atkRoll = RNG.d1000(block.timestamp + atkWinChance);
        uint defRoll = RNG.d1000(block.timestamp + defWinChance + 1);
        // console.log("atkRoll");
        // console.log(atkRoll);
        // console.log("defRoll");
        // console.log(defRoll);

        if (atkRoll < atkWinChance && defRoll < defWinChance) {
            _result = 2;
        } else if (atkRoll > atkWinChance && defRoll > defWinChance) {
            _result = 2;
        } else if (atkRoll > atkWinChance && defRoll < defWinChance) {
            _result = 1;
        } else if (atkRoll < atkWinChance && defRoll > defWinChance) {
            _result = 0;
        } else {
            _result = 2;
        }

        // console.log("_result");
        // console.log(_result);

        finalizeFieldWar(
            _result,
            attacker,
            victim,
            attackerArmyPower,
            defenderArmyPower
        );
    }

    function protect() external {}

    function checkIfTargetInRange(
        Coords memory c1,
        Coords memory c2
    ) public view returns (bool) {
        uint dist = Calculator.calculateDistance(c1, c2);
        if (dist > ACTION_RANGE) {
            revert ErrorExceeds(dist, ACTION_RANGE);
        }
        return true;
    }

    function checkIfSquadOwned(
        Squad memory squad
    ) internal view returns (bool) {
        if (Cities.ownerOf(squad.ControlledBy) != msg.sender) {
            revert ErrorUnauthorized(msg.sender);
        }
        return true;
    }

    function finalizeFieldWar(
        uint result,
        Squad memory attacker,
        Squad memory defender,
        uint atkArmyPower,
        uint defArmyPower
    ) internal {
        // 0 atk win, 1 def win, 2 draw
        /*
        function attackerCasualties(
        uint atkArmyPower,
        uint defArmyPower,
        bool atkHasWon,
        bool draw
    )  */
        uint atkCasualties = Calculator.attackerCasualties(
            atkArmyPower,
            defArmyPower,
            result == 0,
            result == 2
        );
        uint defCasualties = Calculator.defenderCasualties(
            atkArmyPower,
            defArmyPower,
            result == 0,
            result == 2
        );
        // console.log("atkCasualties");
        // console.log(atkCasualties);
        // console.log("defCasualties");
        // console.log(defCasualties);
        // kill atk troops
        bool attackerFullDead = true;
        bool defenderFullDead = true;
        for (uint i = 0; i < attacker.TroopIds.length; i++) {
            attacker.TroopAmounts[i] -=
                (attacker.TroopAmounts[i] * atkCasualties) /
                1000;
            if (attackerFullDead && attacker.TroopAmounts[i] != 0) {
                attackerFullDead = false;
            }
        }

        // kill def troops

        for (uint i = 0; i < defender.TroopIds.length; i++) {
            defender.TroopAmounts[i] -=
                (defender.TroopAmounts[i] * defCasualties) /
                1000;
            if (defenderFullDead && defender.TroopAmounts[i] != 0) {
                defenderFullDead = false;
            }
        }

        // console.log("attackerFullDead");
        // console.log(attackerFullDead);
        // console.log("defenderFullDead");
        // console.log(defenderFullDead);
        TroopsManager.editSquad(attacker, attackerFullDead);
        TroopsManager.editSquad(defender, defenderFullDead);

        emit PlotFight(
            attacker.ID,
            defender.ID,
            result,
            atkCasualties,
            defCasualties
        );
        /* if (result == 0) {
            // atk side win
        } else if (result == 1) {
            // def side win
        } else if (result == 2) {
            // draw
        } */
    }

    function fieldWarArmyPowerFormula(
        Squad memory attacker,
        Squad memory victim
    ) internal view returns (uint, uint) {
        (
            uint attackerAtk,
            uint attackerSiegeAtk,
            uint attackerDef,
            uint attackerSiegeDef,
            uint attackerHp,

        ) = Troops.armyPower(attacker.TroopIds, attacker.TroopAmounts);
        // calculate defender stats

        (
            uint defenderAtk,
            uint defenderSiegeAtk,
            uint defenderDef,
            uint defenderSiegeDef,
            uint defenderHp,

        ) = Troops.armyPower(victim.TroopIds, victim.TroopAmounts);

        return (
            ((attackerAtk + attackerDef) * 2) +
                (attackerSiegeAtk + attackerSiegeDef) +
                attackerHp *
                2,
            ((defenderAtk + defenderDef) * 2) +
                (defenderSiegeAtk + defenderSiegeDef) +
                defenderHp *
                2
        );
    }
}
