// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {PlotContent, Coords, Plot} from "./WorldStructs.sol";

interface IGameWorld {
    function CityCoords(uint256) external view returns (int256 X, int256 Y);

    function CoordsToCity(int256, int256) external view returns (uint256);

    function CoordsToPlot(
        int256,
        int256
    )
        external
        view
        returns (
            int256 Climate,
            PlotContent memory Content,
            bool IsTaken,
            uint256 CityId
        );

    function WorldState()
        external
        view
        returns (
            int256 LastXPositive,
            int256 LastXNegative,
            int256 LastYPositive,
            int256 LastYNegative
        );

    function cos(uint16 _angle) external pure returns (int256);

    function createCity(
        Coords memory coords,
        bool pickClosest,
        uint8 race
    ) external returns (Coords memory _coords);

    function distanceBetweenTwoPoints(
        Coords memory a,
        Coords memory b
    ) external view returns (uint256);

    function isPlotEmpty(Coords memory coords) external view returns (bool);

    function plotProps(
        Coords memory _coords
    ) external view returns (Plot memory _plot);

    function scanCitiesBetweenCoords(
        int256 startX,
        int256 endX,
        int256 startY,
        int256 endY
    ) external view returns (Coords[] memory, uint256[] memory);

    function scanPlots(
        int256 startX,
        int256 endX,
        int256 startY,
        int256 endY
    ) external view returns (Coords[] memory);

    function scanPlotsForEmptyPlace(
        int256 startX,
        int256 endX,
        int256 startY,
        int256 endY
    ) external view returns (Coords memory _coords);
}
