// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {Research} from "./ResearchStructs.sol";

interface IResearchs {
    function allResearchs() external pure returns (Research[] memory);

    function researchInfo(
        uint256 researchId
    ) external pure returns (Research memory);
}
