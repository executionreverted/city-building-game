// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import {ICities} from "../City/ICity.sol";
import {City} from "../City/CityStructs.sol";
import {Race} from "../City/CityEnums.sol";
import {World, Coords} from "./WorldStructs.sol";
import {InvalidWorldCoordinates} from "../Utils/Errors.sol";
import "hardhat/console.sol";

contract GameWorld {
    ICities Cities;
    World public WorldState;
    mapping(uint => Coords) public CityCoords;
    mapping(int => mapping(int => uint)) public CoordsToCity;

    constructor(address _cities) {
        Cities = ICities(_cities);
    }

    function createCity(
        Coords memory coords,
        bool pickClosest
    ) external returns (Coords memory _coords) {
        uint nextToken = Cities.totalSupply();
        bool isEmpty = isPlotEmpty(coords);
        if ((!isEmpty && !pickClosest) || (coords.X == 0 || coords.Y == 0))
            revert InvalidWorldCoordinates(coords.X, coords.Y);

        _coords = getNextCity(coords, true);

        Cities.mintCity(
            msg.sender,
            City({
                Coords: _coords,
                Explorer: msg.sender,
                Race: Race.Human,
                Alive: true
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
            if (x == 0) continue;
            for (int y = startY; y < endY; y++) {
                if (y == 0) continue;
                if (CoordsToCity[x][y] == 0) {
                    _coords.X = x;
                    _coords.Y = y;
                    return _coords;
                }
            }
        }
    }
}
