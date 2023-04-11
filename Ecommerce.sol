//SPDX-License-Identifier: UNLICENSED 

pragma solidity >=0.5.0 < 0.9.0;

contract Ecommerce {
    struct Product {
        string title;
        string desc;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool delivered;
    }
    address payable manager;
    bool destroyed = false;

    constructor() {
        manager = payable(msg.sender);
    }

    uint counter = 1;
    Product[] public products;

    event registered(string title, uint productId,address seller);
    event bought(uint productId,address buyer);
    event delivered(uint productId);

    modifier isNotDestroyed() {
        require(!destroyed, "Contract does not exist");
        _;
    }

    function registerProduct(string memory _title, string memory _desc, uint _price ) public isNotDestroyed {
        require(_price > 0, "Price should be greater than zero");
        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price * 10 ** 18;
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title,tempProduct.productId,msg.sender);
    }

    function buy(uint _productId) public payable isNotDestroyed {
        require(products[_productId - 1].price == msg.value, "Pay the exact price" );
        require(products[_productId - 1].seller != msg.sender, "Seller cannot buy" );
        products[_productId - 1].buyer = msg.sender;
        emit bought(_productId, msg.sender);
    }

    function delivery(uint _productId) public isNotDestroyed {
        require(products[_productId - 1].buyer == msg.sender, "Only buyer can confirm" );
        products[_productId - 1].delivered = true;
        products[_productId - 1].seller.transfer(products[_productId - 1].price );
        emit delivered(_productId);
    }

    function destroy() public isNotDestroyed {
        require(manager == msg.sender, "only manager can call this");
        manager.transfer(address(this).balance);
        destroyed = true;
    }

    fallback() external payable {
        payable(msg.sender).transfer(msg.value);
    }
}
