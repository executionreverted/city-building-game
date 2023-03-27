// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {ICities} from "../City/ICity.sol";
import {ICalculator} from "../Core/ICalculator.sol";
import {IPerlinNoise} from "../Utils/IPerlinNoise.sol";
import {Trigonometry} from "../Utils/Trigonometry.sol";
import {Resource} from "../Resources/ResourceEnums.sol";
import {City} from "../City/CityStructs.sol";
import {Race} from "../City/CityEnums.sol";
import {World, Coords, Plot, PlotContentTypes} from "./WorldStructs.sol";
import {InvalidWorldCoordinates} from "../Utils/Errors.sol";
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";

contract GameWorld is Trigonometry, UpgradeableGameContract {
    bytes32 constant version = keccak256("0.0.1");
    // constants
    uint constant BASE_PLOT_INTERACTION_COOLDOWN = 15 minutes;
    uint constant BASE_RESOURCE_SPAWN_AMOUNT = 100;
    uint constant MAX_PLOT_TIER = 5;
    uint constant DISTANCE_PER_PLOT = 2000;
    uint constant DISTANCE_TIME = 2 minutes;
    int constant PERLIN_05 = 32768;
    int constant PERLIN_1 = 32768 * 2;
    int constant NOISE_AMOUNT = 15;
    uint EVENT_MAP_SEED;

    ICalculator public Calculator;
    ICities public Cities;
    IPerlinNoise public PerlinNoise;

    World public WorldState;
    mapping(uint => Coords) public CityCoords;
    mapping(int => mapping(int => uint)) public CoordsToCity;
    mapping(int => mapping(int => Plot)) public CoordsToPlot;

    function initialize(
        address _cities,
        address _calc,
        address _perl
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        Calculator = ICalculator(_calc);
        PerlinNoise = IPerlinNoise(_perl);
        EVENT_MAP_SEED = 123456789;
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
            if (coords.X - 100 > WorldState.LastXPositive)
                revert InvalidWorldCoordinates(coords.X, coords.Y);
        } else {
            if (coords.X + 100 < WorldState.LastXNegative)
                revert InvalidWorldCoordinates(coords.X, coords.Y);
        }

        if (coords.Y > 0) {
            if (coords.Y - 100 > WorldState.LastYPositive)
                revert InvalidWorldCoordinates(coords.X, coords.Y);
        } else {
            if (coords.Y + 100 < WorldState.LastYNegative)
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
        CoordsToPlot[_coords.X][_coords.Y].IsTaken = true;

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
        Plot memory _plot = plotProps(coords);
        return
            (_plot.Content.Type == PlotContentTypes.HABITABLE &&
                !CoordsToPlot[coords.X][coords.Y].IsTaken) ||
            CoordsToCity[coords.X][coords.Y] == 0;
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
                resultPlots[i] = generatePlotContent(
                    resultPlots[i],
                    Coords({X: x, Y: y})
                );

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

    function plotProps(
        Coords memory _coords
    ) public view returns (Plot memory _plot) {
        // param 1
        // use cos and noise

        if (_coords.X == 0 && _coords.Y == 0) revert("zero");

        _plot.IsTaken = CoordsToPlot[_coords.X][_coords.Y].IsTaken;
        _plot = generatePlotContent(_plot, _coords);

        if (_plot.IsTaken) {
            _plot.CityId = CoordsToCity[_coords.X][_coords.Y];
        }
    }

    function generatePlotContent(
        Plot memory _plot,
        Coords memory _coords
    ) internal  view returns (Plot memory) {
        if (CoordsToPlot[_coords.Y][_coords.Y].IsTaken) {
            _plot.Content.Type = PlotContentTypes.TAKEN;
            return _plot;
        }
        uint256 a = uint256(
            uint256(_coords.X < 0 ? _coords.X * -1 : _coords.X) * 25
        );
        uint256 b = uint256(
            uint256(_coords.Y < 0 ? _coords.Y * -1 : _coords.Y) * 25
        );
        if (a > type(uint16).max) {
            a = type(uint16).max;
        }
        if (b > type(uint16).max) {
            b = type(uint16).max;
        }

        _plot.Climate = PerlinNoise.noise2d(
            sin(uint16(a % 65536)) * NOISE_AMOUNT,
            sin(uint16(b % 65536)) * NOISE_AMOUNT
        );

        // todo content
        uint randomness1 = useRandom(_coords, 316942069, 100); // determine if has plot content & what type it is
        uint randomness2 = useRandom(_coords, 420, 100); // determine plot content type e.g Resource Food
        uint randomness3 = useRandom(_coords, 69420, 100); // determine plot content content tier @MAX_PLOT_TIER
        uint randomness4 = useRandom(_coords, 3142069, 100); // determine param1 min value
        uint randomness5 = useRandom(_coords, 315269420, 100); // determine param2 max value
        // 5%
        bool inhabitable = randomness1 <= 5 ||
            (_plot.Climate < 1 || _plot.Climate > 25);

        if (inhabitable) {
            _plot.Content.Type = PlotContentTypes.INHABITABLE;
            return _plot;
        }

        bool hasContent = randomness1 <= 15;

        if (hasContent) {
            uint foundContent = ((randomness1 + 1)) % 5;

            _plot.Content.Type = PlotContentTypes(foundContent + 2);

            // select resource type
            _plot.Content.Tier = uint8(
                ((randomness3 * 1337601) % MAX_PLOT_TIER) + 1
            );
            if (_plot.Content.Type == PlotContentTypes.RESOURCE) {
                // set resource type in this case.
                if (randomness2 >= 0 && randomness2 < 20) {
                    _plot.Content.Value1 = uint(Resource.GOLD);
                } else if (randomness2 >= 20 && randomness2 < 40) {
                    _plot.Content.Value1 = uint(Resource.WOOD);
                } else if (randomness2 >= 40 && randomness2 < 60) {
                    _plot.Content.Value1 = uint(Resource.STONE);
                } else if (randomness2 >= 60 && randomness2 < 80) {
                    _plot.Content.Value1 = uint(Resource.IRON);
                } else if (randomness2 >= 80 && randomness2 <= 100) {
                    _plot.Content.Value1 = uint(Resource.FOOD);
                }
                // Min.
                _plot.Content.Value2 =
                    ((BASE_RESOURCE_SPAWN_AMOUNT * _plot.Content.Tier) *
                        randomness4) /
                    100;
                // Max.
                _plot.Content.Value3 =
                    _plot.Content.Value2 +
                    (_plot.Content.Value2 * randomness5) /
                    100;
            }
        } else {
            _plot.Content.Type = PlotContentTypes.HABITABLE;
        }

        return _plot;
    }

    function generateNumberFromCoordsAndSeed(
        Coords memory coords,
        uint externalSeed
    ) internal view returns (uint) {
        uint random = uint256(
            keccak256(
                abi.encodePacked(
                    coords.X,
                    coords.Y,
                    address(this),
                    EVENT_MAP_SEED,
                    externalSeed
                )
            )
        );
        return random;
    }

    function useRandom(
        Coords memory coords,
        uint seed,
        uint modulus
    ) internal view returns (uint) {
        return (generateNumberFromCoordsAndSeed(coords, seed) % modulus) + 1;
    }
}
