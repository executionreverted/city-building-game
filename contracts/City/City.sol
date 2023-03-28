// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ImmutableERC721PermissionedMintable} from "../Utils/ImmutableERC721PermissionedMintable.sol";
import {ImmutableERC721Base} from "../Utils/ImmutableERC721Base.sol";
import {Coords} from "../World/WorldStructs.sol";
import {City, Building} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {ICities} from "./ICity.sol";
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "./ICityManager.sol";

// Token
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";

// Access Control
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "../Utils/IERC173.sol";

// Utils
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

contract Cities is ICities, ImmutableERC721PermissionedMintable {
    // _mintNextToken(to);
    bytes32 constant version = keccak256("0.0.1");

    ICityManager CityManager;
    mapping(uint => City) public CityList;
    mapping(uint => Building[25]) public BuildingLevels;

    function initialize(
        address _owner,
        string memory _name,
        string memory _symbol,
        string memory __baseURI,
        string memory _contractURI,
        address _cityManager
    ) external initializer {
        ___initialize(_owner, _name, _symbol, __baseURI, _contractURI);
        grantRole(MINTER_ROLE, _cityManager);
        CityManager = ICityManager(_cityManager);
        _mintNextToken(address(this));
    }

    function mintCity(
        address to,
        City memory _city
    ) external onlyRole(MINTER_ROLE) {
        _mintNextToken(to);
        uint id = totalSupply() - 1;
        CityList[id] = _city;
        for (uint i = 0; i < 5; i++) {
            BuildingLevels[id][i].Tier = 1;
        }
    }

    function upgradeBuilding(
        uint cityId,
        uint buildingId
    ) external onlyRole(MINTER_ROLE) returns (bool) {
        BuildingLevels[cityId][buildingId].Tier++;
    }

    function updateCityCoords(
        uint cityId,
        Coords memory _param
    ) external onlyRole(MINTER_ROLE) returns (bool) {
        CityList[cityId].Coords = _param;
    }

    function updateCityRace(
        uint cityId,
        Race _param
    ) external onlyRole(MINTER_ROLE) returns (bool) {
        CityList[cityId].Race = _param;
    }

    function updateCityAlive(
        uint cityId,
        bool _param
    ) external onlyRole(MINTER_ROLE) returns (bool) {
        CityList[cityId].Alive = _param;
    }

    function updateCityPopulation(
        uint cityId,
        uint _param
    ) external onlyRole(MINTER_ROLE) returns (bool) {
        CityList[cityId].Population = _param;
    }

    function city(uint cityId) external view returns (City memory) {
        return CityList[cityId];
    }

    function citiesOf(address player) external view returns (City[] memory) {
        City[] memory result = new City[](balanceOf(player));
        uint[] memory _tokensOfOwner = new uint[](balanceOf(player));
        uint i;
        for (i = 0; i < _tokensOfOwner.length; i++) {
            _tokensOfOwner[i] = tokenOfOwnerByIndex(player, i);
            result[i] = CityList[_tokensOfOwner[i]];
        }
        return result;
    }

    /// @dev Returns the supported interfaces
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ImmutableERC721Base, IERC165Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function cityPopulation(
        uint cityId
    ) external view override returns (uint) {}

    function ownerOf(
        uint cityId
    )
        public
        view
        override(ICities, IERC721Upgradeable, ERC721Upgradeable)
        returns (address)
    {
        return super.ownerOf(cityId);
    }
}
