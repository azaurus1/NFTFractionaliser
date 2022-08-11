// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "../Fractionaliser.sol";
import "../MyNFT.sol";

contract FractionaliserTest is DSTest {
    Fractionaliser fractionaliser = new Fractionaliser();
    MyNFT NFT = new MyNFT();
    Vm vm ;
    function setUp() public {
    }

    //Test Fractionaliser Bools
    function testInitialised() public {
        assertTrue(!fractionaliser.initialised());
    }
    function testSellable() public {
        assertTrue(!fractionaliser.sellable());
    }

    //Test Fractionaliser Functions
    function testInitialise() public {
        address[] memory addressArray;
        addressArray[1] = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        fractionaliser.initialise(address(NFT), 1, 1e18, addressArray);
    }
    function testMakeSellable() public {
        fractionaliser.makeSellable();
        assertTrue(fractionaliser.sellable());
    }

    //Test NFT functions
    function testNFTMint() public {
        NFT.safeMint(address(1),1);
        assertEq(NFT.ownerOf(1), address(1));
    }
    
}
