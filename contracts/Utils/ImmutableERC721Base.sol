//SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;

// Token
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";

// Access Control
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./IERC173.sol";

// Utils
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

/*
    ImmutableERC721Base is an abstract contract that offers minimum preset functionality without
    an opinionated form of minting. This contract is intended to be inherited and implement it's
    own minting functionality to meet the needs of the inheriting contract.
*/

abstract contract ImmutableERC721Base is
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable,
    AccessControlUpgradeable,
    IERC173
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    ///     =====   State Variables  =====

    /// @dev Contract level metadata.
    string public contractURI;

    /// @dev Common URIs for individual token URIs.
    string public baseURI;

    /// @dev the tokenId of the next NFT to be minted.
    CountersUpgradeable.Counter private nextTokenId;

    /// @dev Owner of the contract (defined for interopability with applications, e.g. storefront marketplace)
    address private _owner;

    ///     =====   Constructor  =====

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE` to the supplied `owner_` address
     *
     * Sets the name and symbol for the collection
     * Sets the default admin to `owner`
     * Sets the `baseURI` and `tokenURI`
     */
    function __initialize(
        address owner_,
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory contractURI_
    ) internal initializer {
        // Initialize state variables
        __ERC721_init(name_, symbol_);
        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
        _owner = owner_;
        baseURI = baseURI_;
        contractURI = contractURI_;

        // Increment nextTokenId to start from 1 (default is 0)
        nextTokenId.increment();

        // Emit events
        emit OwnershipTransferred(address(0), _owner);
    }

    ///     =====   View functions  =====

    /// @dev Returns the baseURI
    function _baseURI()
        internal
        view
        virtual
        override(ERC721Upgradeable)
        returns (string memory)
    {
        return baseURI;
    }

    /// @dev Returns the supported interfaces
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable,
            IERC165
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /// @dev Returns the current owner
    function owner() external view override returns (address) {
        return _owner;
    }

    ///     =====  External functions  =====

    /// @dev Allows admin to set the base URI
    function setBaseURI(
        string memory baseURI_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseURI = baseURI_;
    }

    /// @dev Allows admin to set the contract URI
    function setContractURI(
        string memory _contractURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        contractURI = _contractURI;
    }

    /// @dev Allows admin to update contract owner. Required that new oner has admin role
    function transferOwnership(
        address newOwner
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, newOwner),
            "New owner does not have default admin role"
        );
        address owner_ = _owner;
        require(owner_ != newOwner, "New owner is currently owner");
        require(msg.sender == owner_, "Caller must be current owner");
        _owner = newOwner;
        emit OwnershipTransferred(owner_, newOwner);
    }

    /// @dev Internal hook implemented in {ERC721Enumerable}, required for totalSupply()
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /// @dev Internal function to mint a new token with the next token ID
    function _mintNextToken(address to) internal virtual returns (uint256) {
        uint256 newTokenId = nextTokenId.current();
        super._mint(to, newTokenId);
        nextTokenId.increment();
        return newTokenId;
    }
}
