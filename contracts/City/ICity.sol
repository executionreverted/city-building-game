import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface ICities is IERC721Enumerable {
    function mint(address to, uint256 amount) external;
}
