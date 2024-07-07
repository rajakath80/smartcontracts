// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;

import "./SimpleEcommerce.sol";

/**
    @author rkathiresan
    @title Retail eCommerce store
*/
contract RetailEcommerce is SimpleEcommerce {
    /**
        @dev sets default favorite retail product number
        overrides setFavoriteProduct from SimpleEcommerce
        @param productNumber - favorite product number
    */
    function setFavoriteProduct(uint256 productNumber) public override {
        myFavoriteProduct = productNumber + 5;
    }
}
