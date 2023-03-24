// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ImmutableERC721PermissionedMintable} from "@imtbl/zkevm-contracts/contracts/token/erc721/ImmutableERC721PermissionedMintable.sol";
import {City} from "./CityStructs.sol";
import {ICities} from "./ICity.sol";

contract Cities is ICities, ImmutableERC721PermissionedMintable {
    // _mintNextToken(to);
    bytes32 constant version = keccak256("0.1.4");

    mapping(uint => City) CityList;

    constructor(
        address owner,
        string memory name,
        string memory symbol,
        string memory baseURI,
        string memory contractURI,
        address worldManager
    )
        ImmutableERC721PermissionedMintable(
            owner,
            name,
            symbol,
            baseURI,
            contractURI
        )
    {
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
}
