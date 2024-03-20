// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/src/Test.sol";
import "../src/Token.sol";

contract MyTokenTest is Test {
    MyToken myToken;
   // ErrorsTest testContract;

    function setUp() public {
        vm.prank(address(1));
        myToken = new MyToken(1000, address(1));
       // testContract = new ErrorsTest();
    }

    // Test to check the initial balance of the deployer
    function testInitialBalance() public {
        assertEq(myToken.balanceOf(address(1)), 1000);
    }

    // Test to check the delegate function
    function testDelegate() public {
        vm.prank(address(1));
        myToken.delegate(address(2));
        assertEq(myToken.votingPower(address(2)), 1000);
    }

    // Test to check the revokeDelegate function
    function testRevokeDelegate() public {
        vm.startPrank(address(1));
        myToken.delegate(address(2));
        myToken.revokeDelegate();
        assertEq(myToken.votingPower(address(1)), 1000);
        assertEq(myToken.votingPower(address(2)), 0);
        vm.stopPrank();
    }

    // Test to check the mintRewards function
    function testMintRewards() public {
        vm.startPrank(address(1));
        address voter = address(2);
        myToken.delegate(voter);
        myToken.mintRewards(voter);
        assertEq(myToken.balanceOf(voter), 10000);
        vm.stopPrank();
    }
}


