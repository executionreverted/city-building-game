// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICities} from "../City/ICity.sol";

contract Resources is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;

    function initialize(address _cities) external initializer {
        Cities = ICities(_cities);
    }
}
