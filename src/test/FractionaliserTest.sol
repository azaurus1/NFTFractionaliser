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
    
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        fractionaliser = new Fractionaliser();
        Nft = new MyNFT();
    }

    //Test Fractionaliser Bools
    //function testInitialised() public {
    //    assertTrue(!fractionaliser.initialised());
    //}
    function testSellable() public {
        assertTrue(!fractionaliser.sellable());
    }

    //Test Fractionaliser Functions
    function testMakeSellable() public {
        fractionaliser.makeSellable();
        assertTrue(fractionaliser.sellable());
    }

    //Test NFT functions
    function testNFTMint() public {
        Nft.safeMint(address(1),1);
        assertEq(Nft.ownerOf(1), address(1));
    }
    
}
