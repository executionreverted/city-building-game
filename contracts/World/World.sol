// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {ICities} from "../City/ICity.sol";
import {ICalculator} from "../Core/ICalculator.sol";
import {IPerlinNoise} from "../Utils/IPerlinNoise.sol";
import {ITrigonometry} from "../Utils/ITrigonometry.sol";
import {City} from "../City/CityStructs.sol";
import {Race} from "../City/CityEnums.sol";
import {World, Coords, Plot} from "./WorldStructs.sol";
import {InvalidWorldCoordinates} from "../Utils/Errors.sol";
import "hardhat/console.sol";
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";

contract GameWorld is UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    // constants
    uint constant DISTANCE_PER_PLOT = 2000;
    uint constant DISTANCE_TIME = 2 minutes;
    int constant PERLIN_05 = 32768;
    int constant PERLIN_1 = 32768 * 2;

    ICalculator public Calculator;
    ICities public Cities;
    IPerlinNoise public PerlinNoise;
    ITrigonometry public Trigonometry;

    World public WorldState;
    mapping(uint => Coords) public CityCoords;
    mapping(int => mapping(int => uint)) public CoordsToCity;

    function initialize(
        address _cities,
        address _calc,
        address _perl,
        address _trig
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        Calculator = ICalculator(_calc);
        PerlinNoise = IPerlinNoise(_perl);
        Trigonometry = ITrigonometry(_trig);
    }

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setPerlinNoise(address _cities) external onlyOwner {
        PerlinNoise = IPerlinNoise(_cities);
    }

    function setCalculator(address _calc) external onlyOwner {
        Calculator = ICalculator(_calc);
    }

    function setTrigonometry(address _trig) external onlyOwner {
        Trigonometry = ITrigonometry(_trig);
    }

    function createCity(
        Coords memory coords,
        bool pickClosest,
        Race race
    ) external returns (Coords memory _coords) {
        uint nextToken = Cities.totalSupply();
        bool isEmpty = isPlotEmpty(coords);
        if ((!isEmpty && !pickClosest) || (coords.X == 0 || coords.Y == 0))
            revert InvalidWorldCoordinates(coords.X, coords.Y);

        if (coords.X > 0) {
            if (coords.X - 10 > WorldState.LastXPositive)
                revert InvalidWorldCoordinates(coords.X, coords.Y);
        } else {
            if (coords.X + 10 < WorldState.LastXNegative)
                revert InvalidWorldCoordinates(coords.X, coords.Y);
        }

        if (coords.Y > 0) {
            if (coords.Y - 10 > WorldState.LastYPositive)
                revert InvalidWorldCoordinates(coords.X, coords.Y);
        } else {
            if (coords.Y + 10 < WorldState.LastYNegative)
                revert InvalidWorldCoordinates(coords.X, coords.Y);
        }

        _coords = getNextCity(coords, true);

        Cities.mintCity(
            msg.sender,
            City({
                Coords: _coords,
                Explorer: msg.sender,
                Race: race,
                Alive: true,
                CreationDate: block.timestamp,
                Population: 50
            })
        );
        CoordsToCity[_coords.X][_coords.Y] = nextToken;

        if (_coords.X > 0) {
            if (WorldState.LastXPositive < _coords.X)
                WorldState.LastXPositive = _coords.X;
        } else {
            if (WorldState.LastXNegative > _coords.X)
                WorldState.LastXNegative = _coords.X;
        }

        if (_coords.Y > 0) {
            if (WorldState.LastYPositive < _coords.Y)
                WorldState.LastYPositive = _coords.Y;
        } else {
            if (WorldState.LastYNegative > _coords.Y)
                WorldState.LastYNegative = _coords.Y;
        }

        CityCoords[nextToken] = _coords;
    }

    function getNextCity(
        Coords memory requestedCoords,
        bool flip
    ) internal view returns (Coords memory _finalCoords) {
        if (isPlotEmpty(requestedCoords)) return requestedCoords;

        _finalCoords = requestedCoords;

        while (!isPlotEmpty(_finalCoords)) {
            if (_finalCoords.X == _finalCoords.Y || flip) {
                if (_finalCoords.X > 0) {
                    _finalCoords.X++;
                } else {
                    _finalCoords.X--;
                }
            } else {
                if (_finalCoords.Y > 0) {
                    _finalCoords.Y++;
                } else {
                    _finalCoords.Y--;
                }
            }
            flip = !flip;
        }

        return getNextCity(_finalCoords, flip);
    }

    function isPlotEmpty(Coords memory coords) public view returns (bool) {
        return CoordsToCity[coords.X][coords.Y] == 0;
    }

    function scanCitiesBetweenCoords(
        int startX,
        int endX,
        int startY,
        int endY
    ) external view returns (City[] memory, uint[] memory) {
        require(startX < endX && startY < endY, "start must be lower");
        uint resultLen = uint(endX - startX) * uint(endY - startY);
        uint i;
        City[] memory resultCities = new City[](resultLen);
        uint[] memory resultCityIds = new uint[](resultLen);

        for (int x = startX; x < endX; x++) {
            for (int y = startY; y < endY; y++) {
                uint cityId = CoordsToCity[x][y];
                if (cityId == 0) continue;
                resultCities[i] = Cities.city(cityId);
                resultCityIds[i] = cityId;
                i++;
            }
        }

        return (resultCities, resultCityIds);
    }

    function scanPlotsForEmptyPlace(
        int startX,
        int endX,
        int startY,
        int endY
    ) external view returns (Coords memory _coords) {
        for (int x = startX; x < endX; x++) {
            for (int y = startY; y < endY; y++) {
                if (x == 0 && y == 0) continue;
                if (CoordsToCity[x][y] == 0) {
                    _coords.X = x;
                    _coords.Y = y;
                    return _coords;
                }
            }
        }
    }

    function scanPlots(
        int256 startX,
        int256 endX,
        int256 startY,
        int256 endY
    ) external view returns (Plot[] memory) {
        uint i;
        int xRange = endX - startX;
        int yRange = endY - startY;
        uint resultLen = uint(xRange * yRange);
        Plot[] memory resultPlots = new Plot[](resultLen);
        for (int x = startX; x < endX; x++) {
            for (int y = startY; y < endY; y++) {
                if (x == 0 && y == 0) continue;
                uint256 a = uint256(uint256(x < 0 ? x * -1 : x) * 25);
                uint256 b = uint256(uint256(y < 0 ? y * -1 : y) * 25);
                if (a > type(uint16).max) {
                    a = type(uint16).max;
                }
                if (b > type(uint16).max) {
                    b = type(uint16).max;
                }
                resultPlots[i] = Plot({
                    Weather: PerlinNoise.noise2d(
                        sin(uint16(a % 65536)),
                        sin(uint16(b % 65536))
                    )
                });
                i++;
            }
        }

        return resultPlots;
    }

    function distanceBetweenTwoPoints(
        Coords memory a,
        Coords memory b
    ) public view returns (uint) {
        return Calculator.calculateDistance(a, b);
    }


        // Table index into the trigonometric table
    uint constant INDEX_WIDTH = 4;
    // Interpolation between successive entries in the tables
    uint constant INTERP_WIDTH = 8;
    uint constant INDEX_OFFSET = 12 - INDEX_WIDTH;
    uint constant INTERP_OFFSET = INDEX_OFFSET - INTERP_WIDTH;
    uint16 constant ANGLES_IN_CYCLE = 16384;
    uint16 constant QUADRANT_HIGH_MASK = 8192;
    uint16 constant QUADRANT_LOW_MASK = 4096;
    uint constant SINE_TABLE_SIZE = 16;

    // constant sine lookup table generated by gen_tables.py
    // We have no other choice but this since constant arrays don't yet exist
    uint8 constant entry_bytes = 2;
    bytes constant sin_table = "\x00\x00\x0c\x8c\x18\xf9\x25\x28\x30\xfb\x3c\x56\x47\x1c\x51\x33\x5a\x82\x62\xf1\x6a\x6d\x70\xe2\x76\x41\x7a\x7c\x7d\x89\x7f\x61\x7f\xff";

    /**
     * Convenience function to apply a mask on an integer to extract a certain
     * number of bits. Using exponents since solidity still does not support
     * shifting.
     *
     * @param _value The integer whose bits we want to get
     * @param _width The width of the bits (in bits) we want to extract
     * @param _offset The offset of the bits (in bits) we want to extract
     * @return An integer containing _width bits of _value starting at the
     *         _offset bit
     */
    function bits(uint _value, uint _width, uint _offset) pure internal returns (uint) {
        return (_value / (2 ** _offset)) & (((2 ** _width)) - 1);
    }

    function sin_table_lookup(uint index) pure internal returns (uint16) {
        bytes memory table = sin_table;
        uint offset = (index + 1) * entry_bytes;
        uint16 trigint_value;
        assembly {
            trigint_value := mload(add(table, offset))
        }

        return trigint_value;
    }

    /**
     * Return the sine of an integer approximated angle as a signed 16-bit
     * integer.
     *
     * @param _angle A 14-bit angle. This divides the circle into 16384
     *               angle units, instead of the standard 360 degrees.
     * @return The sine result as a number in the range -32767 to 32767.
     */
    function sin(uint16 _angle) public pure returns (int) {
        uint interp = bits(_angle, INTERP_WIDTH, INTERP_OFFSET);
        uint index = bits(_angle, INDEX_WIDTH, INDEX_OFFSET);

        bool is_odd_quadrant = (_angle & QUADRANT_LOW_MASK) == 0;
        bool is_negative_quadrant = (_angle & QUADRANT_HIGH_MASK) != 0;

        if (!is_odd_quadrant) {
            index = SINE_TABLE_SIZE - 1 - index;
        }

        uint x1 = sin_table_lookup(index);
        uint x2 = sin_table_lookup(index + 1);
        uint approximation = ((x2 - x1) * interp) / (2 ** INTERP_WIDTH);

        int sine;
        if (is_odd_quadrant) {
            sine = int(x1) + int(approximation);
        } else {
            sine = int(x2) - int(approximation);
        }

        if (is_negative_quadrant) {
            sine *= -1;
        }

        return sine;
    }

    /**
     * Return the cos of an integer approximated angle.
     * It functions just like the sin() method but uses the trigonometric
     * identity sin(x + pi/2) = cos(x) to quickly calculate the cos.
     */
    function cos(uint16 _angle) public pure returns (int) {
        if (_angle > ANGLES_IN_CYCLE - QUADRANT_LOW_MASK) {
            _angle = QUADRANT_LOW_MASK - ANGLES_IN_CYCLE - _angle;
        } else {
            _angle += QUADRANT_LOW_MASK;
        }
        return sin(_angle);
    }

}
