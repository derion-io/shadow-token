const chai = require("chai")
const { solidity } = require("ethereum-waffle")
chai.use(solidity)

const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const bn = ethers.BigNumber.from
// const { ethers } = require("hardhat");

const MAX_INT = bn('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')


describe("Shadow test", function () {
  async function fixture() {
    const [owner, accountA, accountB] = await ethers.getSigners();

    const ShadowFactory = await ethers.getContractFactory('ShadowFactoryMintable')
    let shadowFactory = await ShadowFactory.deploy()
    await shadowFactory.deployed()
    // shadowFactory = await ethers.getContractAt('IShadowFactoryMintable', shadowFactory.address, owner)

    await shadowFactory.deployShadow(1)
    const shadow = await ethers.getContractAt('Shadow', await shadowFactory.computeShadowAddress(1), owner)

    const FakeShadow = await ethers.getContractFactory('FakeShadow')
    const fakeShadow = await FakeShadow.deploy(shadowFactory.address, 1)
    await fakeShadow.deployed()
    
    await shadowFactory.mint(owner.address, 1, 1000000, 0x0)

    return {
      owner,
      accountA,
      accountB,
      shadow,
      shadowFactory,
      fakeShadow
    }
  }

  it("Only shadow can call safeTransferFromByShadow", async function() {
    const {owner, accountA, shadowFactory, fakeShadow} = await loadFixture(fixture)

    await expect(shadowFactory.safeTransferFromByShadow(
      owner.address,
      accountA.address,
      1,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')

    await expect(fakeShadow.transferFrom(
      owner.address,
      accountA.address,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')
  })

  describe("Transfer", function () {
    it("Should balance exact same between ERC20 and ERC1155", async function() {
      const {shadow, shadowFactory, accountA, owner} = await loadFixture(fixture)
      const erc20Balance = await shadow.balanceOf(owner.address)
      const erc1155Balance = await shadowFactory.balanceOf(owner.address, 1)
      expect(erc20Balance).to.be.equal(erc1155Balance)
    })
    it("Transfer success from ERC20", async function () {
      const {shadow, shadowFactory, accountA, owner} = await loadFixture(fixture)
      const erc20BalanceBefore = await shadow.balanceOf(owner.address)
      await shadow.transfer(accountA.address, "100")
      const erc20BalanceAfter = await shadow.balanceOf(owner.address)
      expect(erc20BalanceBefore.sub(erc20BalanceAfter)).to.be.equal(bn('100'))
      expect(await shadow.balanceOf(accountA.address)).to.be.equal(bn('100'))
    })
    it("Transfer exceed balance", async function () {
      const {shadow, shadowFactory, accountA, owner} = await loadFixture(fixture)
      const erc20BalanceBefore = await shadow.balanceOf(owner.address)
      await expect(
        shadow.transfer(accountA.address, erc20BalanceBefore.add(1).toString())
      ).to.be.revertedWith('balance')
      await expect(shadowFactory.safeTransferFrom(
        owner.address, 
        accountA.address, 
        1, 
        erc20BalanceBefore.add(1).toString(),
        0x0
      )).to.be.revertedWith('Maturity: insufficient balance')
    })
    it("Transfer to contract", async function () {
      const {shadow, shadowFactory, fakeShadow, owner} = await loadFixture(fixture)
      await shadow.transfer(fakeShadow.address, '100');
      await expect(shadowFactory.safeTransferFrom(
        owner.address, 
        fakeShadow.address, 
        1, 
        '100',
        0x0
      )).to.be.revertedWith('ERC1155: transfer to non-ERC1155Receiver implementer')
    })
    it("Approve 1155 and use 20 to transfer", async function () {
      const {shadow, shadowFactory, owner, accountA, accountB} = await loadFixture(fixture)
      await shadowFactory.setApprovalForAll(accountA.address, '100');
      const balanceOwnerBefore = await shadow.balanceOf(owner.address)
      const balanceBBefore = await shadow.balanceOf(accountB.address)
      await shadow.connect(accountA).transferFrom(owner.address, accountB.address, '100')
      const balanceOwnerAfter = await shadow.balanceOf(owner.address)
      const balanceBAfter = await shadow.balanceOf(accountB.address)

      expect(balanceBAfter.sub(balanceBBefore)).to.be.equal(bn(100))
      expect(balanceOwnerBefore.sub(balanceOwnerAfter)).to.be.equal(bn(100))
    })

    it("Approve 1155 and allowance 20 should be max", async function () {
      const {shadow, shadowFactory, owner, accountA} = await loadFixture(fixture)
      await shadowFactory.setApprovalForAll(accountA.address, '100');    
      const shadowAllowance = await shadow.allowance(owner.address, accountA.address)
      expect(shadowAllowance).to.be.equal(MAX_INT)
    })
  })
})