// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

interface ITrigonometry {
    function sin(uint16 _angle) external pure returns (int);

    /**
     * Return the cos of an integer approximated angle.
     * It functions just like the sin() method but uses the trigonometric
     * identity sin(x + pi/2) = cos(x) to quickly calculate the cos.
     */
    function cos(uint16 _angle) external pure returns (int);
}
