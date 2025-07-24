const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");

describe("TechnoLimeStore", function () {
  async function deployTechnoLimeStore() {
    const TechnoLimeStore = await ethers.getContractFactory("TechnoLimeStore");
    const technoLimeStore = await TechnoLimeStore.deploy();
    const [admin, otherAccount] = await ethers.getSigners();
    return { technoLimeStore, admin, otherAccount };
  }

  describe("TechnoLimeStore functionalities", function () {
    it("Should return product 1 on getProductsIds call", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      const id = await technoLimeStore.getProductsIds();
      expect(id[0]).to.be.equal(1);
    });
    it("Should check admin", async function () {
      const { technoLimeStore, admin } = await loadFixture(
        deployTechnoLimeStore
      );
      expect(await technoLimeStore.admin()).to.equal(admin.address);
    });
    it("Should create product", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.createOrUpdateProduct(999, 2);
      const ids = await technoLimeStore.getProductsIds();
      expect(ids[1]).to.be.equal(999);
    });
    it("Should update product quantity", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.createOrUpdateProduct(1, 5);
      const quantities = await technoLimeStore.getProductsQuantities();
      expect(quantities[0]).to.be.equal(5);
    });
    it("Should return error- not admin", async function () {
      const { technoLimeStore, otherAccount } = await loadFixture(
        deployTechnoLimeStore
      );
      await expect(
        technoLimeStore.connect(otherAccount).createOrUpdateProduct(2, 5)
      ).to.be.revertedWith("Only admin has this rights");
    });
    it("Buyer should be able to buy products", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.buyProduct(1, { value: 1 });
      const quantities = await technoLimeStore.getProductsQuantities();
      expect(quantities[0]).to.be.equal(0);
    });
    it("Should return error - product does not exist error", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await expect(
        technoLimeStore.buyProduct(2, { value: 1 })
      ).to.be.revertedWith("This product does not exist");
    });
    it("Should return error - out of stock", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.createOrUpdateProduct(1, 0);
      await expect(
        technoLimeStore.buyProduct(1, { value: 1 })
      ).to.be.revertedWith("This product is out of stock");
    });
    it("Should return error - already purchased", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.buyProduct(1, { value: 1 });
      await technoLimeStore.createOrUpdateProduct(1, 1);
      await expect(
        technoLimeStore.buyProduct(1, { value: 1 })
      ).to.be.revertedWith("You have already purchased this product");
    });
    it("Should return error - send 1 wei to purchased", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await expect(technoLimeStore.buyProduct(1)).to.be.revertedWith(
        "You need to send 1 wei to buy the product"
      );
    });
    it("Buyer should be able to return products", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.buyProduct(1, { value: 1 });
      await technoLimeStore.returnProduct(1);
      let quantities = await technoLimeStore.getProductsQuantities();
      expect(quantities[0]).to.be.equal(1);
    });
    it("Buyer return error- can no longer return", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.buyProduct(1, { value: 1 });
      await time.increase(3600);
      await expect(technoLimeStore.returnProduct(1)).to.be.revertedWith(
        "You can no longer return this product"
      );
    });
    it("Buyer return error- you did not purchase this product", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await expect(technoLimeStore.returnProduct(2)).to.be.revertedWith(
        "You did not buy this product"
      );
    });
    it("Should return the buyers of a product", async function () {
      const { technoLimeStore } = await loadFixture(deployTechnoLimeStore);
      await technoLimeStore.buyProduct(1, { value: 1 });
      const buyers = await technoLimeStore.getAddressOfProductBuyers(1);
      expect(buyers[0]).to.be.equal(await technoLimeStore.admin());
    });

    it("Should return the balance of the contract", async function () {
      const { technoLimeStore, admin } = await loadFixture(
        deployTechnoLimeStore
      );
      await technoLimeStore.buyProduct(1, { value: 1 });
      const balance = await technoLimeStore.getContractBalance();
      expect(balance).to.be.equal(1);
    });
  });
});
