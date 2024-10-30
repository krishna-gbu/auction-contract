// // SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Auction {
    address s_owner;
    // string startTime;
    mapping(address => uint256) public bidderAddAndValue;
    bool isAuctionStart = false;
    uint highestBid;
    address highestBidder;
    uint auctionEndTime;
    string public item;
    mapping(address => uint) public pendingReturns;

    /// event  ////
    event newHigestBid(address highestBidder, uint256 highestBid);
    event endAuctionEvent(address highestBidder, uint256 highestBid);

    constructor() {
        s_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(s_owner == msg.sender, "Only owner call this function");
        _;
    }

    modifier isEndAuction() {
        require(
            block.timestamp > auctionEndTime,
            "auction is end try in Other Auctions"
        );
        _;
    }

    function startAuction(
        uint256 minBidAmount,
        uint256 duration,
        string memory whatItem
    ) public onlyOwner {
        isAuctionStart = true;
        highestBid = minBidAmount;
        auctionEndTime = block.timestamp + duration;
        item = whatItem;
    }

    function bid() public payable isEndAuction {
        ///bid is greater then highestBid///
        require(msg.value > highestBid, "Bid is not Enough");

        ///check address is not be the zero address///
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        ///assign new value to bid///
        highestBid = msg.value;
        highestBidder = msg.sender;
        emit newHigestBid(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];

        pendingReturns[msg.sender] = 0;

        if (!payable(msg.sender).send(amount)) {
            pendingReturns[msg.sender] = amount;
            return false;
        }

        return true;
    }

    function endAuction() public onlyOwner {
        require(isAuctionStart, "Auction is not start");
        require(block.timestamp > auctionEndTime, "Auction is Ongoing");

        /// auction is ///
        isAuctionStart = false;

        /// payment transfer to owner///
        payable(s_owner).transfer(highestBid);
        emit endAuctionEvent(highestBidder, highestBid);
    }
}
