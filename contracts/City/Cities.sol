// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ImmutableERC721PermissionedMintable} from "../Utils/ImmutableERC721PermissionedMintable.sol";
import {ImmutableERC721Base} from "../Utils/ImmutableERC721Base.sol";
import {Coords} from "../World/WorldStructs.sol";
import {City, Building} from "./CityStructs.sol";
import {Race} from "./CityEnums.sol";
import {ICities} from "./ICities.sol";
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

contract Cities is ImmutableERC721PermissionedMintable {
    event CityCreated(uint indexed cityId, address indexed owner, Coords coords);

    // _mintNextToken(to);
    bytes32 constant version = keccak256("0.0.1");

    ICityManager CityManager;

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
        Coords memory _coords,
        Race _race
    ) external onlyRole(MINTER_ROLE) returns (uint) {
        _mintNextToken(to);
        uint id = totalSupply();
        CityManager.setCity(
            id,
            City({
                Coords: _coords,
                Explorer: to,
                Race: _race,
                Alive: true,
                CreationDate: block.timestamp,
                Population: 50
            })
        );
        emit CityCreated(id, to, _coords);
        return id;
    }

    function tokensOfOwner(
        address player
    ) external view returns (uint[] memory) {
        uint[] memory _tokensOfOwner = new uint[](balanceOf(player));
        uint i;
        for (i = 0; i < _tokensOfOwner.length; i++) {
            _tokensOfOwner[i] = tokenOfOwnerByIndex(player, i);
        }
        return _tokensOfOwner;
    }
}
