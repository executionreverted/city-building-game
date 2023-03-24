// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";

contract PlayerController is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
}
