// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;

import "./SimpleEcommerce.sol";

/**
    @author rkathiresan
    @title Simple eCommerce factory
*/
contract SimpleEcommerceFactory {
    SimpleEcommerce[] public ecommContractsList;

    /**
        @dev creates a simple ecommerce contract
    */
    function createSimpleEcommerceContract() public {
        SimpleEcommerce newContract = new SimpleEcommerce();
        ecommContractsList.push(newContract);
    }

    /**
        @dev returns no of ecommerce contracts
        @return contracts count
    */
    function getContractsCount() public view returns (uint256) {
        return ecommContractsList.length;
    }

    /**
        @dev sets fav product for specified ecomm store
        @param _ecommStore - store index in storesList
        @param _favProduct - new favorite product number
    */
    function setFavoriteProduct(
        uint256 _ecommStore,
        uint256 _favProduct
    ) public {
        SimpleEcommerce ecommStore = ecommContractsList[_ecommStore];
        ecommStore.setFavoriteProduct(_favProduct);
    }

    /**
        @dev returns fav product for specified ecomm store
        @param _ecommStore - store index in storesList
    */
    function getFavoriteProduct(
        uint256 _ecommStore
    ) public view returns (uint256) {
        SimpleEcommerce ecommStore = ecommContractsList[_ecommStore];
        return ecommStore.getFavoriteProduct();
    }
}
