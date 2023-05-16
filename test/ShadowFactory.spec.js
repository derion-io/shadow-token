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

    const FakeShadow = await ethers.getContractFactory('FakeShadow')
    const fakeShadow = await FakeShadow.deploy(shadowFactory.address, 1)
    await fakeShadow.deployed()
    
    await shadowFactory.mint(owner.address, 1, 1000000, 0x0)

    return {
      owner,
      accountA,
      shadow,
      shadowFactory,
      fakeShadow
    }
  }

  it("Only shadow can call safeTransferFromByShadow", async function() {
    const {owner, accountA, shadowFactory, fakeShadow} = await loadFixture(fixture)

    await expect(shadowFactory.safeTransferFromByShadow(
      owner.address,
      owner.address,
      accountA.address,
      1,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')

    await expect(fakeShadow.transfer(
      accountA.address,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')
  })

  it("Only shadow can call setApprovalForAllByShadow", async function() {
    const {owner, accountA, shadowFactory, fakeShadow} = await loadFixture(fixture)

    await expect(shadowFactory.setApprovalForAllByShadow(
      1,
      owner.address,
      owner.address,
      accountA.address
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')

    await expect(fakeShadow.approve(
      accountA.address,
      100
    )).to.be.revertedWith('Shadow: UNAUTHORIZED')
  })
})