## Assignment

Please go through the chapters in order to prepare yourself fot the challenge.

[1. Intro to Blockchain](https://www.notion.so/limechain/01-Intro-to-Blockchain-for-FE-developers-93f81fc4999340e490e86474ee66fdc5)

[2. Intro to Ethereum](https://www.notion.so/limechain/02-Intro-to-Ethereum-1e345fc59b5a4608899df6ab96282d0a)

[3. Solidity - All you need to know](https://www.notion.so/limechain/03-Solidity-all-you-need-to-know-about-it-b67341cb42454ac88454f5b29169f510)

You challenge is to create the following smart contract:
## Your Contract

Using Remix/Hardhat develop a contract for a TechnoLime Store.

- The administrator (owner) of the store should be able to add new products and the quantity of them. +
- The administrator should not be able to add the same product twice, just quantity. + 
- Buyers (clients) should be able to see the available products and buy them by their id. +
- Buyers should be able to return products if they are not satisfied (within a certain period in blocktime: 100 blocks).+
- A client cannot buy the same product more than one time.+
- The clients should not be able to buy a product more times than the quantity in the store unless a product is returned or added by the administrator (owner) +
- Everyone should be able to see the addresses of all clients that have ever bought a given product. +

### Evaluation Criteria
    - Your code should be clean and easy to be read
    - Your code should be with effective method and variable names
    - Your code should contain correct description of the methods
    - [Optional] You should provide deployment scripts [Hardhat]
    - [Optional] You should provide good unit test cases [Hardat]
    - [Optional] You should provide 100% code coverage [Hardat]

### Additional Resources

[Remix](https://remix.ethereum.org/)

[Hardhat Quick Start](https://hardhat.org/hardhat-runner/docs/getting-started#quick-start)

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