// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;

/**
 * @title IERC721
 * @dev Interface for the ERC721 standard.
 */
interface IERC721 {
    function transferFrom(address _from, address _to, uint256 _id) external;
}

/**
 * @title Escrow
 * @dev Escrow contract for handling NFT transactions with collateral and verification.
 */
contract Escrow {
    address public lender;
    address public verifier;
    address payable public seller;
    address public nftAddress;

    /**
     * @dev Modifier to restrict access to only the seller.
     */
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    /**
     * @dev Modifier to restrict access to only the buyer of a specific NFT.
     * @param _nftId The ID of the NFT.
     */
    modifier onlyBuyer(uint256 _nftId) {
        require(msg.sender == buyer[_nftId], "Only buyer can call this method");
        _;
    }

    /**
     * @dev Modifier to restrict access to only the verifier.
     */
    modifier onlyVerifier() {
        require(msg.sender == verifier, "Only verifier can call this method");
        _;
    }

    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public verificationPassed;
    mapping(uint256 => mapping(address => bool)) public approval;
    mapping(uint256 => uint256) public collateralAmount;

    /**
     * @dev Constructor to initialize the escrow contract with necessary addresses.
     * @param _nftAddress The address of the NFT contract.
     * @param _seller The address of the seller.
     * @param _verifier The address of the verifier.
     * @param _lender The address of the lender.
     */
    constructor(
        address _nftAddress,
        address payable _seller,
        address _verifier,
        address _lender
    ) {
        nftAddress = _nftAddress;
        seller = _seller;
        verifier = _verifier;
        lender = _lender;
    }

    /**
     * @notice Lists an NFT for sale.
     * @dev Transfers the NFT to the escrow, sets the purchase price, collateral amount, and assigns the buyer.
     * @param _nftId The ID of the NFT.
     * @param _buyer The address of the buyer.
     * @param _purchasePrice The purchase price of the NFT.
     * @param _collateralAmount The collateral amount required for the NFT.
     */
    function list(
        uint256 _nftId,
        address _buyer,
        uint256 _purchasePrice,
        uint256 _collateralAmount
    ) public payable onlySeller {
        // Transfer NFT to escrow
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftId);

        isListed[_nftId] = true;
        purchasePrice[_nftId] = _purchasePrice;
        collateralAmount[_nftId] = _collateralAmount;
        buyer[_nftId] = _buyer;
    }

    /**
     * @notice Verifies the status of an NFT asset.
     * @dev Sets the verification status of the NFT.
     * @param _nftId The ID of the NFT.
     * @param _passed The verification status.
     */
    function verifyAssetStatus(
        uint256 _nftId,
        bool _passed
    ) public onlyVerifier {
        verificationPassed[_nftId] = _passed;
    }

    /**
     * @notice Deposits collateral for a specific NFT.
     * @dev Requires the caller to be the buyer of the NFT and the collateral amount to be sufficient.
     * @param _nftId The ID of the NFT.
     */
    function depositCollateral(
        uint256 _nftId
    ) public payable onlyBuyer(_nftId) {
        require(
            msg.value >= collateralAmount[_nftId],
            "Insufficient collateral amount."
        );
    }

    /**
     * @notice Approves the sale of a specific NFT.
     * @dev Marks the caller's approval for the sale.
     * @param _nftId The ID of the NFT.
     */
    function approveSale(uint256 _nftId) public {
        approval[_nftId][msg.sender] = true;
    }

    /**
     * @notice Finalizes the sale of a specific NFT.
     * @dev Transfers the purchase price to the seller, the NFT to the buyer, and marks the sale as completed.
     * @param _nftId The ID of the NFT.
     */
    function finalizeSale(uint256 _nftId) public {
        require(verificationPassed[_nftId], "Asset not verified.");
        require(approval[_nftId][buyer[_nftId]], "Buyer approval required.");
        require(approval[_nftId][seller], "Seller approval required.");
        require(
            address(this).balance >= purchasePrice[_nftId],
            "Insufficient balance to finalize sale."
        );

        isListed[_nftId] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );
        require(success, "Payment to seller failed.");

        IERC721(nftAddress).transferFrom(address(this), buyer[_nftId], _nftId);
    }

    /**
     * @notice Cancels the sale of a specific NFT.
     * @dev Refunds the balance to the buyer if verification failed, otherwise to the seller.
     * @param _nftId The ID of the NFT.
     */
    function cancelSale(uint256 _nftId) public {
        if (!verificationPassed[_nftId]) {
            payable(buyer[_nftId]).transfer(address(this).balance);
        } else {
            payable(seller).transfer(address(this).balance);
        }
    }

    /**
     * @dev Fallback function to receive payments.
     */
    receive() external payable {}

    /**
     * @notice Returns the balance of the escrow contract.
     * @return The balance of the escrow contract.
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
