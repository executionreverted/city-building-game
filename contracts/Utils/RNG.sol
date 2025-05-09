// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "./UpgradeableGameContract.sol";

contract RNG is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");

    uint private randomizer;

    function d1000(uint _input) external returns (uint) {
        return dn(_input, 1000);
    }

    function d100(uint _input) external returns (uint) {
        return dn(_input, 100);
    }

    function d20(uint _input) external returns (uint) {
        return dn(_input, 20);
    }

    function d12(uint _input) external returns (uint) {
        return dn(_input, 12);
    }

    function d10(uint _input) external returns (uint) {
        return dn(_input, 10);
    }

    function d8(uint _input) external returns (uint) {
        return dn(_input, 8);
    }

    function d6(uint _input) external returns (uint) {
        return dn(_input, 6);
    }

    function d4(uint _input) external returns (uint) {
        return dn(_input, 4);
    }

    function dn(uint _input, uint _number) public returns (uint) {
        return _seed(_input) % _number;
    }

    function _random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function _seed(uint _input) internal returns (uint rand) {
        randomizer++;
        rand = _random(
            string(
                abi.encodePacked(
                    block.number,
                    uint160(address(this)),
                    gasleft(),
                    randomizer,
                    _input,
                    msg.sender
                )
            )
        );
    }
}
