// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.18;

import { Resource } from "./ResourceEnums.sol";

struct ResourceCost {
    uint Gold;
    uint Wood;
    uint Stone;
    uint Iron;
    uint Food;
    uint[12] __reserveSlot;
}

struct ClaimableResource {
    Resource resource;
    uint256 amount;
    uint256 claimableAfter;
    uint256 deadline;
}