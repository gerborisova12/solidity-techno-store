
### How to run 
- npm i 
- npx hardhat compile
- npx hardhat deploy

### How to test the flow 
    1.Deploy contract - product with id:1, quantity:1, price:1  is created; 
    2.Call createOrUpdateProduct(2,1) - product with id:2, quantity:1 is created. All products are with price:1. Only admin can update or create product.
    3.Call createOrUpdateProduct(2,2) - product 2 is update with quantity 2. 
    4.Insert value to be send- 1 and call buyProduct(2) - you will buy product 2 (if the product is Out of stock or not existing error will be thrown). If you try to buy product 2 from the same account, error will be thrown.
    5.You can see the contract balance by calling getContractBalance();
    6.You can see all the buyers that bought product by calling getAddressOfProductBuyers(id);
    7.Buyer can return the product that he bought by calling returnProduct(id), for 100 block time after purchasing it.
    When the product is returned it's quantity increases and money are returned to buyer.

### How to run the test
- npx hardhat test
- npx hardhat coverage