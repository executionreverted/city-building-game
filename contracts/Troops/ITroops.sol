// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Troop} from "./TroopsStructs.sol";

interface ITroops {
    function troopInfo(uint256 troopId) external pure returns (Troop memory);
}
