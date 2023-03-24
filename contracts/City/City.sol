// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ImmutableERC721PermissionedMintable} from "@imtbl/zkevm-contracts/contracts/token/erc721/ImmutableERC721PermissionedMintable.sol";
import {City} from "./CityStructs.sol";

contract Cities is ImmutableERC721PermissionedMintable {
    // _mintNextToken(to);
    bytes32 constant version = keccak256("0.1.4");

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
        _mintNextToken(msg.sender);
    }
}
