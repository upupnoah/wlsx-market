// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import "../src/Project6551.sol";
import "../src/PreMarket.sol";
import "../src/Project.sol";
import "./BaseERC20.sol";
import "lib/erc6551/src/examples/simple/ERC6551Account.sol";
import "lib/erc6551/src/ERC6551Registry.sol";

contract PreMarketTest is Test {
    ERC6551Registry public registry;
    ERC6551Account public implementation;

    Project project;
    PreMarket preMarket;
    BaseERC20 token;
    address buyer;
    address seller;

    function setUp() public {
        registry = new ERC6551Registry();
        implementation = new ERC6551Account();

        token = new BaseERC20("EIGEN", "EIGEN");
        project = new Project(address(registry), payable(address(implementation)));
        preMarket = new PreMarket(address(project));
        buyer = makeAddr("buyer");
        seller = makeAddr("seller");
        token.transfer(seller, 200);
        vm.deal(seller, 200);
        vm.deal(buyer, 200);
        project.addPreProject("EIGEN", address(token), block.timestamp + 1 hours, block.timestamp + 2 hours, 0);
    }

    function testAddOrderAndMatchOrder() public {
        vm.startPrank(buyer);
        preMarket.addOrder{value: 100}(0, 100, 100, 0, 0);
        preMarket.addOrder{value: 50}(0, 50, 50, 0, 0);
        PreMarket.PreOrder[] memory list = preMarket.preOrdersList(0, 0);
        assertEq(list.length, 2);
        vm.stopPrank();

        vm.startPrank(seller);
        preMarket.matchOrder{value: 50}(1, 50);

        PreMarket.PreOrder[] memory left1 = preMarket.preOrdersList(0, 0);
        assertEq(left1.length, 1);

        preMarket.matchOrder{value: 100}(0, 100);
        PreMarket.PreOrder[] memory left0 = preMarket.preOrdersList(0, 0);
        assertEq(left0.length, 0);
        vm.stopPrank();
    }

    function testDelivery() public {
        testAddOrderAndMatchOrder();
        vm.startPrank(seller);
        token.approve(address(preMarket), 150);
        vm.warp(block.timestamp + 1.5 hours);
        preMarket.delivery(0);
        preMarket.delivery(1);
        assertEq(token.balanceOf(buyer), 150);
    }

    function testRepay() public {
        testAddOrderAndMatchOrder();
        preMarket.setOrderStatus(0, 2);
        vm.warp(block.timestamp + 2.5 hours);

        vm.startPrank(buyer);
        preMarket.repay(0);
        preMarket.repay(1);

        assertEq(token.balanceOf(buyer), 0);
        assertEq(buyer.balance, 350);
    }
}
