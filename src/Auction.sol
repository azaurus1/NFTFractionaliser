// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Auction{
    event Start();
    event Bid(address indexed bidder, uint256 amount);
    event Withdrawal(address indexed requester, uint256 amount);
    event End(address winner, uint256 amount);

    IERC20 public token;
    uint256 public amount;

    address public stakeContract;

    address payable public seller;
    address public owner;
    uint256 public endDate;
    bool public started;
    bool public ended;

    address public winningBidder;
    uint256 public winningBid;

    mapping(address => uint256) public bids;

    constructor(address _token, uint256 _amount, uint256 _startingBid, address _stakeContract, address _owner){
        token = IERC20(_token);
        amount = _amount;
        stakeContract = _stakeContract;
        owner = _owner;
        token.approve(msg.sender, amount);
        token.approve(owner, amount);

        seller = payable(msg.sender);
        winningBid = _startingBid;

    }

    function _startAuction() external {
        require(!started, "This auction has started");
        require(msg.sender == seller, "You are not the seller");

        token.transferFrom(msg.sender, address(this), amount);
        started = true;
        endDate = block.timestamp + 24 hours;

        emit Start();

    }

    function bid() external payable{
        require(started, "This auction has not started");
        require(block.timestamp < endDate,"This auction has ended, you may not bid");
        require(msg.value > winningBid,"You must bid higher than the winning bid");

        if (winningBidder != address(0)){
            bids[winningBidder] += winningBid;
        }

        winningBidder = msg.sender;
        winningBid = msg.value;

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 balance = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(balance);

        emit Withdrawal(msg.sender,balance);
    }

    function end() external {
        require(started,"This auction has not started");
        require(block.timestamp >= endDate, "This auction has ended");
        require(!ended, "this auction has not ended");

        ended = true;
        if(winningBidder != address(0)){
            token.transfer(winningBidder,amount);
            //token.transferFrom(address(this), winningBidder, amount);
        }else{
            token.transfer(winningBidder,amount);
            //token.transferFrom(address(this), seller, amount);
        }

        (bool sent, bytes memory data) = stakeContract.call{value:winningBid}("");
        require(sent,"Failed to send winning bid to stake contract");

        emit End(winningBidder,winningBid);
    }

}