// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ImmutableERC721PermissionedMintable} from "../Utils/ImmutableERC721PermissionedMintable.sol";
import {ImmutableERC721Base} from "../Utils/ImmutableERC721Base.sol";
import {Coords} from "../World/WorldStructs.sol";
import {City} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {ICities} from "./ICity.sol";
import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";

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

    mapping(uint => City) CityList;

    function initialize(
        address owner,
        string memory name,
        string memory symbol,
        string memory baseURI,
        string memory contractURI,
        address worldManager
    ) external initializer {
        ___initialize(owner, name, symbol, baseURI, contractURI);
        grantRole(MINTER_ROLE, worldManager);
        _mintNextToken(address(this));
    }

    function mintCity(
        address to,
        City memory _city
    ) external onlyRole(MINTER_ROLE) {
        _mintNextToken(to);
        uint id = totalSupply();
        CityList[id] = _city;
    }

    function updateCityCoords(
        uint cityId,
        Coords memory _param
    ) external onlyRole(MINTER_ROLE) {
        CityList[cityId].Coords = _param;
    }

    function updateCityRace(
        uint cityId,
        Race _param
    ) external onlyRole(MINTER_ROLE) {
        CityList[cityId].Race = _param;
    }

    function updateCityAlive(
        uint cityId,
        bool _param
    ) external onlyRole(MINTER_ROLE) {
        CityList[cityId].Alive = _param;
    }

    function updateCityPopulation(
        uint cityId,
        uint _param
    ) external onlyRole(MINTER_ROLE) {
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
}
