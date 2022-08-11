// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "./Stake.sol";
import "./Auction.sol";

interface IStake{
    function stake(IERC20 _token, uint256 _amount) external;
    function unstake(IERC20 _token, uint256 _amount) external;
    function setRewards(uint256 _amount) external;
    function distributeRewards() external;
}

contract KeeperCompatibleFractionaliser is ERC20, Ownable, ERC20Permit, ERC721Holder, KeeperCompatibleInterface {
    IERC721 public nft;
    Auction public currentAuction;
    IStake public stakeContract;
    address public keeper;
    uint256 public token;
    bool public initialised = false;
    bool public sellable = false;
    uint256 public price;
    uint256 public initialSupply;
    uint256 public earnings;

    modifier onlyOwnerOrKeeper{
        require(msg.sender == owner() || msg.sender == address(keeper));
        _;
    }

    constructor() ERC20("FractionalNFT", "FNFT") ERC20Permit("FractionalNFT") {}

    function initialise(address _nft, uint256 _tokenId, uint256 _amount, address[] memory _initialAddresses) external onlyOwner{
        require(!initialised, "This is already intialised");
        require(_amount > 0, "Amount is less than 0!");
        nft = IERC721(_nft);
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        token = _tokenId;
        initialised = true;
        for (uint i = 0; i < _initialAddresses.length; i++){
            _mint(_initialAddresses[i], _amount);
        }
        initialSupply = totalSupply();
    }

    function setKeeper(address _keeper) public onlyOwner{
        keeper = _keeper;
    }

    function setStakingContract(address _stakeContract) public onlyOwner{
        require(_stakeContract != address(0),"Address cannot be zero");
        stakeContract = IStake(_stakeContract);
    }

    function makeSellable() external onlyOwner{
        sellable = true;
    }

    function buy() external payable {
        // this will be where the bonus task is, check for majority holding.
        require(balanceOf(msg.sender) > ((totalSupply() / 100)*50),"Must have majority of tokens to buyout the NFT");
        require(sellable, "Not currently for sale");
        nft.transferFrom(address(this), msg.sender, token);
        sellable = false;
    }

    function createAuction() public onlyOwnerOrKeeper{
        currentAuction = new Auction(address(this),((initialSupply/100)*1),100000000000000000,address(stakeContract),owner());
        _mint(address(this),((initialSupply/100)*1));
        this.approve(address(currentAuction),((initialSupply/100)*1));
    }
    function startAuction() public onlyOwnerOrKeeper {
        currentAuction._startAuction();

    }
    function endAuction() public onlyOwnerOrKeeper{
        currentAuction.end();
    }


    function sendRewards() public onlyOwnerOrKeeper {
        earnings = currentAuction.winningBid();
        stakeContract.setRewards(earnings);
        stakeContract.distributeRewards();
        earnings = 0;
    }

    function retrieveDevFee(address _to) public onlyOwner{
        require(address(this).balance > 0, "No dev fees");
        uint256 devFees = address(this).balance;

        (bool sent, bytes memory data) = _to.call{value:devFees}("");
        require(sent,"Failed to send Dev Fees");
    }

    function checkUpkeep(bytes calldata ) external view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp > currentAuction.endDate()) ;
    }

    function performUpkeep(bytes calldata) external override {
        if ((block.timestamp > currentAuction.endDate()) ) {
            endAuction();
            sendRewards();
            createAuction();
            startAuction();
        }
    }

    receive() payable external {}

}