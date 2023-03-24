import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {City} from "./CityStructs.sol";

interface ICities is IERC721Enumerable {
    function mintCity(address to) external;
    function city(uint256 id) external view returns(City memory);
}
