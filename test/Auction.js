import {ethers} from 'hardhat';
const { expect } = require("chai");

describe('Auction', async () => {
  let owner;
  let buyer;
  let auction;
  beforeEach(async function () {
    [owner, buyer] = await ethers.getSigners();
    const AuctionEngine = await ethers.getContractFactory('Auction', owner);
    auction = await AuctionEngine.deploy();
    
  });
});