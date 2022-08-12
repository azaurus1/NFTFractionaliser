// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../Fractionaliser.sol";
import "../MyNFT.sol";
import "../Stake.sol";

contract FractionaliserTest is DSTest {

    Fractionaliser public fractionaliser;
    MyNFT public Nft;
    Stake public stake;
    address[] public tempAddress = new address[](1);
    address public temp = address(0xa52cC7B5931B689b645bCd42ae7fE0431935C5d8);
    
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        fractionaliser = new Fractionaliser();
        Nft = new MyNFT();
        Nft.safeMint(temp, 1);
        tempAddress[0] = msg.sender;
        vm.startPrank(temp);
        Nft.setApprovalForAll(address(fractionaliser), true);
        vm.stopPrank();
    }

    //Test Fractionaliser Bools
    function testInitialised() public {
        assertTrue(!fractionaliser.initialised());
    }
    function testSellable() public {
        assertTrue(!fractionaliser.sellable());
    }

    //Test Fractionaliser Functions
    function testInitialise(uint256 amount) public {
        vm.assume(amount > 0);
        fractionaliser.transferOwnership(temp);
        vm.startPrank(temp);
        fractionaliser.initialise(address(Nft),1,amount,tempAddress);
        vm.stopPrank();
        assertEq(fractionaliser.balanceOf(tempAddress[0]),amount);
    }
    function testMakeSellable() public {
        fractionaliser.makeSellable();
        assertTrue(fractionaliser.sellable());
    }
    function testCannotCreateAuction() public{
        vm.expectRevert(bytes("Stake contract must be set"));
        fractionaliser.createAuction();
    }
    function testCannotStartAuction() public{
        vm.expectRevert(bytes("Current auction contract must be set"));
        fractionaliser.startAuction();
    }
    function testCannotSendRewards() public{
        vm.expectRevert(bytes("Stake contract not set"));
        fractionaliser.sendRewards();
    }
    function testCannotRetrieveDevFees(address to) public {
        vm.expectRevert(bytes("No dev fees"));
        fractionaliser.retrieveDevFee(to);
    }

    //Test NFT functions
    function testNFTMint() public {
        Nft.safeMint(address(1),2);
        assertEq(Nft.ownerOf(2), address(1));
    }
    function testApprovalForAll() public {
        Nft.setApprovalForAll(address(1), true);
        assertTrue(Nft.isApprovedForAll(Nft.owner(), address(1)));
    }

    
    
}
