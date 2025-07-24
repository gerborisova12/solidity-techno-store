// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
import "hardhat/console.sol";

contract TechnoLimeStore {
    address public immutable admin;
    address payable public buyer;
    bool elementExists;
    bool productIsAvailable;
    bool canBePurchased = true;
    uint256 existingElementIndex;
    uint256 purchasedProductIndex;

    struct Product {
        uint256 id;
        uint256 quantity;
        uint256 price;
    }

    Product private product;
    Product[] private products;

    constructor() {
        ///@notice sets the owner of the contract when it's deployed (only 1 time)
        admin = msg.sender;
        ///@notice creates a product id:1,quantity:1,price:1 when cotract is deployed
        products.push(Product(1, 1, 1));
    }

    ///@notice mapping of the buyer's address to the products ids he bought
    ///@custom:example 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db:[1,2,3]
    mapping(address => uint256[]) private buyerProducts;

    ///@notice mapping of the product ids to the buyers' address that've ever purchased it
    ///@custom:example 1:[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,0x3210993Bc481177ec7E8f571ceCaE8A9e22C02db]
    mapping(uint256 => address[]) private productBuyers;

    ///@notice mapping of the product ids to the block timestamp when the purchase was made
    ///@custom:example 1:256
    mapping(uint256 => uint256) private blockWhenPurchased;

    event ProductCreated(uint256 id, uint256 quantity);
    event ProductReturned(uint256 id, address buyer);
    event ProductUpdated(uint256 id, uint256 quantity);
    event ProductPurchased(uint256 id, address buyer);

    ///@notice checks if the user is the admin
    modifier hasAdminRights() {
        require(msg.sender == admin, "Only admin has this rights");
        _;
    }

    ///@notice sets the buyer
    modifier setBuyer() {
        buyer = payable(msg.sender);
        _;
    }

    ///@notice checks if product exists
    ///@dev sets existingElementIndex and elementExists
    modifier productExists(uint256 _id) {
        elementExists = false;
        for (uint256 i = 0; i < products.length; i++) {
            if (products[i].id == _id) {
                existingElementIndex = i;
                elementExists = true;
                break;
            }
        }
        _;
    }

    ///@notice checks if product.quantity is > 0
    ///@dev sets productIsAvailable
    modifier productAvailability(uint256 _id) {
        if (products[existingElementIndex].quantity > 0) {
            productIsAvailable = true;
        } else {
            revert("This product is out of stock");
        }
        _;
    }

    ///@notice checks if the product has been purchased by this buyer
    ///@dev sets canBePurchased,purchasedProductIndex
    modifier alreadyPurchased(uint256 _id) {
        canBePurchased = true;
        for (uint256 i = 0; i < buyerProducts[buyer].length; i++) {
            if (buyerProducts[buyer][i] == _id) {
                canBePurchased = false;
                purchasedProductIndex = i;
            }
        }
        _;
    }

    ///@notice Adds products or edits product quantity.Only admin can use it.
    ///@notice The product price is set to 1 and can't be changed.
    ///@notice If the product exists, only changes the quantity
    ///@dev expects product id and quantity example: 2,3
    function createOrUpdateProduct(uint256 _id, uint256 _quantity)
        external
        hasAdminRights
        productExists(_id)
    {
        if (elementExists == true) {
            products[existingElementIndex].quantity = _quantity;
            console.log(
                "Updating",
                products[existingElementIndex].id,
                "to be",
                products[existingElementIndex].quantity
            );
            emit ProductUpdated(_id, _quantity);
        } else {
            products.push(Product(_id, _quantity, 1));
            emit ProductCreated(_id, _quantity);
            console.log(
                "creating product",
                _id,
                "with price 1 and quantity",
                _quantity
            );
        }
    }

    ///@notice Returns all the product ids
    function getProductsIds() external view returns (uint256[] memory) {
        uint256[] memory id = new uint256[](products.length);
        for (uint256 i = 0; i < products.length; i++) {
            Product memory productToShow = products[i];
            id[i] = productToShow.id;
        }
        return id;
    }

    ///@notice Returns all the products quantities
    ///@notice for testing purposes
    function getProductsQuantities() external view returns (uint256[] memory) {
        uint256[] memory quantity = new uint256[](products.length);
        for (uint256 i = 0; i < products.length; i++) {
            Product memory productToShow = products[i];
            quantity[i] = productToShow.quantity;
        }
        return quantity;
    }

    ///@notice Users can buy products by their ids
    ///@notice Buyer can't buy a product more than once and products that are out of stock
    ///@dev sets buyer
    ///@dev expects product id, example:2
    function buyProduct(uint256 _id)
        external
        payable
        setBuyer
        productExists(_id)
        alreadyPurchased(_id)
        productAvailability(_id)
    {
        require(elementExists, "This product does not exist");
        require(canBePurchased, "You have already purchased this product");
        require(msg.value == 1, "You need to send 1 wei to buy the product");
        productBuyers[_id].push(buyer);
        buyerProducts[buyer].push(_id);
        products[existingElementIndex].quantity -= 1;
        blockWhenPurchased[_id] = (block.timestamp);
        console.log("Product", _id, "purchased");
        emit ProductPurchased(_id, buyer);
    }

    ///@notice Users can return products if 100 blocks after purchased haven't passed
    ///@notice when returned quantity of product is increased and product is removed from buyerProducts mapping
    ///@dev sets buyer
    ///@dev expects product id,example:2
    function returnProduct(uint256 _id)
        external
        setBuyer
        alreadyPurchased(_id)
        productExists(_id)
    {
        require(!canBePurchased, "You did not buy this product");
        uint256 currentBlock = block.timestamp;
        uint256 passedBlocks = currentBlock - blockWhenPurchased[_id];
        require(passedBlocks < 100, "You can no longer return this product");
        buyerProducts[buyer][purchasedProductIndex] = buyerProducts[buyer][
            buyerProducts[buyer].length - 1
        ];
        buyerProducts[buyer].pop();
        products[existingElementIndex].quantity += 1;
        (bool sent, bytes memory data) = buyer.call{value: 1}("");
        require(sent, "Failed to refund wei");
        console.log("Product", _id, "returned");
        emit ProductReturned(_id, buyer);
    }

    ///@notice Returns the contract balance for testing purposes
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    ///@notice Returns the address of the buyers that bought the product
    ///@dev expects product id,example:2
    function getAddressOfProductBuyers(uint256 _id)
        external
        view
        returns (address[] memory)
    {
        address[] memory buyersAddress = new address[](
            productBuyers[_id].length
        );
        for (uint256 i = 0; i < productBuyers[_id].length; i++) {
            address buyers = productBuyers[_id][i];
            buyersAddress[i] = buyers;
        }
        return buyersAddress;
    }
}
