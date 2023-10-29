// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {USDC_V2} from "../src/USDC_V2.sol";

interface USDC_proxy {
    function upgradeTo(address newImplementation) external;
}

contract USDC_V2_Test is Test {
    // FiatTokenProxy proxy;
    USDC_proxy proxy;

    USDC_V2 usdcV2;
    USDC_V2 proxyUsdcV2;

    address owner = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a;
    address admin = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;

    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        uint256 mainnet = vm.createFork(
            "https://eth-mainnet.g.alchemy.com/v2/824UlSSnbsxJCKZj7hLg63cnw9YFq6hT"
        );
        vm.selectFork(mainnet);
        proxy = USDC_proxy(USDC);
    }

    // 測試升級合約
    function testUpgradable() public {
        vm.startPrank(admin);
        // deploys USDC_V2
        usdcV2 = new USDC_V2();
        proxy.upgradeTo(address(usdcV2));
        proxyUsdcV2 = USDC_V2(address(proxy));

        vm.stopPrank();
        // Try to upgrade the proxy to TradingCenterV2
        vm.startPrank(alice);
        proxyUsdcV2.initializedV2();
        assertEq(proxyUsdcV2.initializedv2(), true);
        vm.stopPrank();
    }

    // 測試白名單新增功能
    function testAddWhiteList() public {
        testUpgradable();
        vm.startPrank(owner);
        proxyUsdcV2.addWhiteList(alice);
        // alice 被加入白名單 應該 return true
        assertEq(proxyUsdcV2.isWhiteListed(alice), true);
        // bob 沒被加入白名單 應該 reture false
        assertEq(proxyUsdcV2.isWhiteListed(bob), false);
        vm.stopPrank();
    }

    // 測試白名單轉帳功能
    function testTransfer() public {
        testAddWhiteList();
        vm.startPrank(alice);
        deal(address(proxy), alice, 10 ** 22);

        // alice 在白名單中，所以可以transfer 10000 usdc給 bob
        proxyUsdcV2.transfer(bob, 10 ** 22);
        assertEq(proxyUsdcV2.balanceOf(bob), 10 ** 22);
        vm.stopPrank();

        // bob 不在白名單中，所以不能transfer 10000 usdc還給 alice
        vm.startPrank(bob);
        vm.expectRevert();
        proxyUsdcV2.transfer(alice, 10 ** 22);
        vm.stopPrank();
    }

    // 測試白名單 mint 功能
    function testMintToken() public {
        testAddWhiteList();
        // alice 在白名單中，所以可以mint 10000 usdc, 同時 totalsupply 變多 10000
        vm.startPrank(alice);
        uint256 beforeTotal = proxyUsdcV2.totalSupply();
        proxyUsdcV2.mint(10 ** 22);
        assertEq(proxyUsdcV2.balanceOf(alice), 10 ** 22);
        assertEq(proxyUsdcV2.totalSupply(), beforeTotal + 10 ** 22);
        vm.stopPrank();

        // bob 不在白名單中，所以 mint會fail, 同時 totalsupply不會有變化
        vm.startPrank(bob);
        beforeTotal = proxyUsdcV2.totalSupply();
        vm.expectRevert();
        proxyUsdcV2.mint(10 ** 22);
        assertEq(proxyUsdcV2.totalSupply(), beforeTotal);
        vm.stopPrank();
    }
}
