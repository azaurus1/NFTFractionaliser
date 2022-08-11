// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract Stake is Ownable{

    IERC20 public tokenContract;
    uint256 public rewards;
    uint256 public userIndex;
    uint256 public stakedAmount;
    mapping(address => uint256) public stakes;
    mapping (uint256 => address) public stakedUsers;


    event Staked(address user, uint256 amount);
    event Unstaked(address user, uint256 amount);

    constructor(IERC20 _tokenAddress){
        require(address(_tokenAddress)!=address(0),"Token address is invalid");
        tokenContract = _tokenAddress;
        rewards = 0;
        userIndex = 0;
    }

    function setRewards(uint256 _amount) public onlyOwner{
        require(_amount > 0, "Cannot set the rewards to 0");
        rewards += _amount;
    }

    function calculateShare(address _userAddress) public view returns (uint256 share){
        share = ((stakes[_userAddress]*10**4 / stakedAmount) +5 )/10;
        return share;
    }

    function distributeRewards() public onlyOwner{
        for (uint256 i=0; i< userIndex;i++){
            uint256 share = calculateShare(stakedUsers[i]);
            uint256 rewardShare = (rewards / 1000) * share;
            (bool sent, bytes memory data) = stakedUsers[i].call{value:rewardShare}("");
            require(sent,"failed to send eth rewards");
        }
        rewards = 0;
    }

    function stake(IERC20 _token, uint256 _amount) public{
        require(_token == tokenContract, "You cannot stake this token here");
        require(_amount <= tokenContract.balanceOf(msg.sender),"You cannot stake more tokens than you have");
        tokenContract.transferFrom(msg.sender, address(this), _amount);
        if (stakes[msg.sender] == 0){
            stakedUsers[userIndex] = address(msg.sender);
            userIndex +=1;
        }
        stakedAmount += _amount;
        stakes[msg.sender] += _amount;
        emit Staked(msg.sender, _amount);
    }

    function unstake(IERC20 _token, uint256 _amount) public {
        require(stakes[msg.sender] >= _amount,"You do not have that many tokens staked");
        require(_token == tokenContract,"You cannot unstake this token here");
        stakes[msg.sender] -= _amount;
        tokenContract.transfer(msg.sender,_amount);
        emit Unstaked(msg.sender, _amount);
    }

    receive() external payable{}



}