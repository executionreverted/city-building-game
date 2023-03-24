// SPDX-License-Identifier: GPL3.0 

pragma solidity ^0.8.18;

interface IPerlinNoise {
    function noise2d(int256 x, int256 y) external pure returns (int256);
}