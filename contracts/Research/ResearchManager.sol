// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.18;

import {UpgradeableGameContract} from "../Utils/UpgradeableGameContract.sol";
import {ICityManager} from "../City/ICityManager.sol";
import {ICities} from "../City/ICities.sol";
import {Race} from "../City/CityEnums.sol";
import {Coords} from "../City/CityStructs.sol";
import {IGameWorld} from "../World/IWorld.sol";
import {Resource} from "../Resources/ResourceEnums.sol";
import {IResources} from "../Resources/IResources.sol";
import {ICalculator} from "../Core/ICalculator.sol";
import {IResearchs} from "./IResearchs.sol";
import {Research} from "./ResearchStructs.sol";
import {EnumerableSetUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

contract ResearchManager is UpgradeableGameContract {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    bytes32 constant version = keccak256("0.0.1");
    ICities Cities;
    ICityManager CityManager;
    IResources Resources;
    ICalculator Calculator;
    IGameWorld World;
    IResearchs Researchs;
    uint constant RESEARCH_CENTER_ID = 9;
    uint constant MAX_RESOURCE_ID = 5;
    mapping(uint => uint[100]) CityResearchesValidAfter;

    // movement stuff

    function initialize(
        address _cities,
        address _cityManager,
        address _resources,
        address _world,
        address _researchs
    ) external initializer {
        _initialize();
        Cities = ICities(_cities);
        CityManager = ICityManager(_cityManager);
        Resources = IResources(_resources);
        World = IGameWorld(_world);
        Researchs = IResearchs(_researchs);
    }

    function setCities(address _cities) external onlyOwner {
        Cities = ICities(_cities);
    }

    function setCityManager(address _cityManager) external onlyOwner {
        CityManager = ICityManager(_cityManager);
    }

    function setWorld(address _world) external onlyOwner {
        World = IGameWorld(_world);
    }

    function setResearchs(address _res) external onlyOwner {
        Researchs = IResearchs(_res);
    }

    modifier onlyCityOwner(uint cityId) {
        address _owner = Cities.ownerOf(cityId);
        require(_owner == msg.sender, "unauthorized");
        _;
    }

    function beginResearch(
        uint cityId,
        uint researchId
    ) external onlyCityOwner(cityId) {
        // must be not researched
        require(
            CityResearchesValidAfter[cityId][researchId] == 0,
            "already on"
        );

        // burn resources
        Research memory _research = Researchs.researchInfo(researchId);
        uint researchCenterTier = CityManager.buildingLevel(
            cityId,
            RESEARCH_CENTER_ID
        );
        require(
            researchCenterTier >= _research.MinResearchCenterLevel,
            "low tier"
        );
        uint[] memory toBeBurn = new uint[](MAX_RESOURCE_ID);
        for (uint i = 0; i < MAX_RESOURCE_ID; i++) {
            toBeBurn[i] = _research.Cost[i];
        }
        Resources.spendResources(cityId, toBeBurn);
        // set completion time

        CityResearchesValidAfter[cityId][researchId] =
            block.timestamp +
            _research.TimeRequired;
    }

    function researchTime(
        uint cityId,
        uint resId
    ) external view returns (uint) {
        return CityResearchesValidAfter[cityId][resId];
    }

    function isResearched(
        uint cityId,
        uint researchId
    ) public view returns (bool) {
        uint validAfter = CityResearchesValidAfter[cityId][researchId];
        if (validAfter != 0 && block.timestamp >= validAfter) return true;
        return false;
    }

    function isResearchedBatch(
        uint cityId,
        uint[] memory researchIds
    ) public view returns (bool[] memory) {
        bool[] memory result = new bool[](researchIds.length);
        for (uint i = 0; i < researchIds.length; ) {
            uint validAfter = CityResearchesValidAfter[cityId][researchIds[i]];
            if (validAfter != 0 && block.timestamp >= validAfter) {
                result[i] = true;
            }
            unchecked {
                i++;
            }
        }
        return result;
    }
}
