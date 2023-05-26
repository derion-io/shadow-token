const chai = require("chai")
const { solidity } = require("ethereum-waffle")
chai.use(solidity)

const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");
// const { ethers } = require("hardhat");

describe("Shadow test", function () {
  async function fixture() {
    const [owner, accountA, accountB] = await ethers.getSigners();

    const ShadowFactory = await ethers.getContractFactory('ShadowFactoryTest')
    const shadowFactory = await ShadowFactory.deploy()
    await shadowFactory.deployed()

    await shadowFactory.deployShadow(1)
    const shadow = await ethers.getContractAt('Shadow', await shadowFactory.computeShadowAddress(1), owner)

    const Helper = await ethers.getContractFactory('Helper')
    const helper = await Helper.deploy(shadowFactory.address, 1)
    await helper.deployed()
    
    await shadowFactory.mint(owner.address, 1, 1000000, 0x0)

    return {
      owner,
      accountA,
      shadow,
      shadowFactory,
      helper
    }
  }

  it("Only shadow can call safeTransferFromByShadow", async function() {
    const {owner, accountA, shadowFactory, helper} = await loadFixture(fixture)

    await expect(shadowFactory.safeTransferFromByShadow(
      owner.address,
      accountA.address,
      1,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')

    await expect(helper.transferFrom(
      owner.address,
      accountA.address,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')
  })

  it("Only shadow can call setApprovalForAllByShadow", async function() {
    const {owner, accountA, shadowFactory, helper} = await loadFixture(fixture)

    await expect(shadowFactory.setApprovalForAllByShadow(
      1,
      owner.address,
      owner.address,
      accountA.address
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')

    await expect(helper.approve(
      accountA.address,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')
  })
})