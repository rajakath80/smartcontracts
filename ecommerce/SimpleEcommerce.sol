// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.5.0 <0.9.0;

/**
    @author rkathiresan
    @title Simple eCommerce store
*/
contract SimpleEcommerce {
    //favoriteproduct set to 0
    uint256 myFavoriteProduct;

    /// Customer struct
    struct Customer {
        //stores favorite product of the customer
        uint256 favoriteProduct;
        //stores name of the customer
        string customerName;
    }

    //array of customers
    Customer[] public customers;

    //customer1 -> favorite productId
    mapping(string => uint256) public customerToFavoriteProduct;

    /**
        @dev sets default favorite product number
        virtual - children can override this function
        @param productNumber - favorite product number
    */
    function setFavoriteProduct(uint256 productNumber) public virtual {
        myFavoriteProduct = productNumber;
    }

    /**
        @dev returns default favorite product number
        @return Favorite product number
    */
    function getFavoriteProduct() public view returns (uint256) {
        return myFavoriteProduct;
    }

    /**
        @dev adds a customer with his name and favorite product
        @param _name - customer name
        @param _favoriteProduct - favorite product number
    */
    function addCustomer(string memory _name, uint256 _favoriteProduct) public {
        customers.push(Customer(_favoriteProduct, _name));
        customerToFavoriteProduct[_name] = _favoriteProduct;
    }
}
