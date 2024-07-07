// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @title Aircraft real world asset token
 * @dev ERC721 token representing aircrafts with metadata storage and marketplace approval.
 */
contract Aircraft is ERC721URIStorage {
    uint256 private _tokenIdCounter = 0;

    address private marketplaceAddress;

    mapping(uint256 => address) private _owners;

    /**
     * @dev Emitted when a new token is minted.
     * @param tokenId The ID of the newly minted token.
     * @param tokenURI The URI of the token metadata.
     * @param marketplaceAddress The address of the marketplace with approval for the token.
     */
    event TokenMinted(
        uint256 indexed tokenId,
        string tokenURI,
        address marketplaceAddress
    );

    /**
     * @dev Constructor to set the marketplace address and initialize the ERC721 contract.
     * @param _marketplaceAddress The address of the marketplace contract.
     */
    constructor(address _marketplaceAddress) ERC721("Aircraft", "AIR") {
        marketplaceAddress = _marketplaceAddress;
    }

    /**
     * @notice Mints a new token with the given URI.
     * @dev Mints a token, sets its URI, gives marketplace approval, and emits a TokenMinted event.
     * @param tokenURI The URI of the token metadata.
     * @return The ID of the newly minted token.
     */
    function mint(string memory tokenURI) public returns (uint256) {
        uint256 newTokenId = _tokenIdCounter++;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        _owners[newTokenId] = msg.sender;

        // give marketplace approval to transact NFTs between users
        setApprovalForAll(marketplaceAddress, true);

        emit TokenMinted(newTokenId, tokenURI, marketplaceAddress);
        return newTokenId;
    }

    /**
     * @notice Returns the total number of minted tokens.
     * @return The total supply of tokens.
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }

    /**
     * @notice Gets the creator of a token by its ID.
     * @param tokenId The ID of the token.
     * @return The address of the token creator.
     */
    function getTokenCreatorById(
        uint256 tokenId
    ) public view returns (address) {
        return _owners[tokenId];
    }

    /**
     * @notice Returns the IDs of all tokens owned by the caller.
     * @return An array of token IDs owned by the caller.
     */
    function getOwnedTokens() public view returns (uint256[] memory) {
        uint256 numberOfExistingTokens = _tokenIdCounter;
        uint256 numberOfTokensOwned = balanceOf(msg.sender);
        uint256[] memory ownedTokenIds = new uint256[](numberOfTokensOwned);

        uint256 currentIndex = 0;
        for (uint256 i = 0; i < numberOfExistingTokens; i++) {
            uint256 tokenId = i;
            if (ownerOf(tokenId) != msg.sender) continue;
            ownedTokenIds[currentIndex] = tokenId;
            currentIndex += 1;
        }
        return ownedTokenIds;
    }

    /**
     * @notice Returns the IDs of all tokens created by the caller.
     * @return An array of token IDs created by the caller.
     */
    function getCreatedTokens() public view returns (uint256[] memory) {
        uint256 numberOfExistingTokens = _tokenIdCounter;
        uint256 numberOfTokensCreated = 0;

        for (uint256 i = 0; i < numberOfExistingTokens; i++) {
            uint256 tokenId = i;
            if (_owners[tokenId] != msg.sender) continue;
            numberOfTokensCreated += 1;
        }

        uint256[] memory createdTokenIds = new uint256[](numberOfTokensCreated);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < numberOfExistingTokens; i++) {
            uint256 tokenId = i;
            if (_owners[tokenId] != msg.sender) continue;
            createdTokenIds[currentIndex] = tokenId;
            currentIndex += 1;
        }

        return createdTokenIds;
    }
}
