// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "hardhat/console.sol";

contract Auction {

  address public owner;
  uint constant FEE = 10;

  event LotCreated(uint index, string item, uint startingPrice, uint rate, uint startAt, uint endAt);
  event AuctinoEnded(uint index, uint price);
  
  struct Lot {
    address payable seller;
    uint startingPrice;
    uint lastPrice;
    uint rate;
    uint startAt;
    uint endAt;
    bool isSold;
    bool isEnded;
    string item;
  }

  Lot[] public lots;

  constructor() {
    owner = msg.sender;
  }

  function createLot(
    uint _startingPrice,
    uint _rate,
    uint _startAt,
    string calldata _item,
    uint _duration
  ) external {
    require(_startingPrice > 0, 'You must provide starting price!');
    require(_rate > 0, 'You must provide rate!');
    require(_startAt > block.timestamp, 'Incorrect startAt!');
    require(bytes(_item).length > 0, 'You must provide item!');
    Lot memory lot = Lot({
      seller: payable(msg.sender),
      startingPrice: _startingPrice,
      lastPrice: 0,
      rate: _rate,
      startAt: _startAt,
      endAt: _startAt + _duration,
      isSold: false,
      isEnded: false,
      item: _item
    });
    lots.push(lot);
    emit LotCreated(lots.length - 1, lot.item, lot.startingPrice, lot.rate, lot.startAt, lot.endAt);
  }

  function getPriceFor(uint _index) public view returns(uint) {
    Lot memory currentLot = lots[_index];
    if (block.timestamp < currentLot.startAt) {
      return currentLot.startingPrice;
    }
    if (currentLot.isSold || currentLot.isEnded) {
      return currentLot.lastPrice;
    }
    uint elapsed = block.timestamp - currentLot.startAt;
    uint discount = currentLot.rate * elapsed;
    uint currentPrice = currentLot.startingPrice - discount;
    return currentPrice;
  }

  function buy(uint _index) payable public {
    Lot storage currentLot = lots[_index];
    require(!currentLot.isEnded, 'Bidding completed!');
    currentLot.isEnded = true;
    currentLot.isSold = true;
    uint currentPrice = getPriceFor(_index);
    currentLot.lastPrice = currentPrice;
    require(msg.value >= currentPrice, 'Not enough money!');
    currentLot.seller.transfer(currentPrice - ((currentPrice) * FEE) / 100);
    emit AuctinoEnded(_index, currentPrice);
  }
}