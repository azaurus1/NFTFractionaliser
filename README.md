# NFTFractionaliser - Fractional NFT Smart Contract with Staking and Auction functionality

## Contracts
* Fractionaliser.sol
* KeeperCompatibleFractionaliser.sol
* Auction.sol
* Stake.sol
* MyNFT.sol

## Graph
![Untitled Diagram drawio](https://user-images.githubusercontent.com/59070507/184132177-8d037626-7f21-4fad-8142-db284643c4ae.png)

## Explanation

### Fractionaliser.sol

The Fractionaliser contract takes and ERC721 NFT and locks it up, creating ERC20 token (FNFT) shares representing the shares in the locked NFT, these shares 
are distributed evenly amongst a array of initial addresses. 

The Stake contract allows holders of the FNFT token to stake their tokens, without time limit, 
and receive rewards which are provided from the auction contracts. 

Every day, the Fractionaliser mints 1% of its initial supply, creates an auction contract,and transfers those newly minted FNFT tokens to it, the Auction is an implementation of an english auction, starting at 0.1ETH as the initial price. On a successful auction,
the bidder receives the newly minted FNFT tokens, and the ETH earned minus a 5% dev fee is sent to the Stake contract.

Once the current auction in the Fractionaliser is set to ended, the Fractionaliser will request the stake contract to disburse the earnings to each of the stakers 
proportionally to their staked FNFT in the Stake contract.

If the Fractionaliser is set to Sellable by the owner, and an FNFT holder manages to accumulate over 50% of the total supply of FNFT, it is possible for them to buy the locked NFT out by paying their FNFT and receiving the underlying NFT.

### KeeperCompatibleFractionaliser.sol
The KeeperCompatibileFractionaliser contract has all of the above still applicable except that, it is entirely on-chain and uses a custom logic Chainlink keeper, to automate its functions. This improves it's decentralisation compared to the above implementation, as the above
will need to be run either manually by and operator, or can be automated using any web3 app. But the KeeperCompatible version will be run entirely on-chain with the use of Chainlink Keepers.

## Setup Steps
1. Deploy the MyNFT Contract
2. safeMint() an NFT to a given address with a tokenId
3. Deploy the Fractionaliser Contract
4. on the MyNFT contract, use setApprovalForAll, using the Fractionaliser address as the address and true for the Bool
5. on the Fractionaliser contract, use initialise(), with _nft as the address for MyNFT, _tokenId as the tokenId for the NFT, _amount as the amount of FNFT you wish to create per initial address e.g. 1000000000000000000 = 1 FNFT, _intialAddresses as a bytes encoded string representation of an address array e.g. ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"]
6. Deploy the Stake contract, giving the address of the Fractionaliser contract as the tokenAddress.
7. on the Fractionaliser contract, use setStakingContract(), with _stakeContract set to the address of the Stake contract.
8. on the Fractionaliser contract, use the createAuction() function, this will create an Auction and will set Fractionaliser.currentAuction to the address of the new Auction.
9. on the Fractionaliser contract, use the startAuction function, this will start the currentAuction, setting its endDate to block.timestamp = 24 hours
10. the Fractionaliser system is now set up, automation can be set up with a seperate web3 Python or Javascript application to automate checking auction status.

