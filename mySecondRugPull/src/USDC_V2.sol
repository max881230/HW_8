// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {FiatTokenV2_1, FiatTokenV1, IERC20} from "./USDC.sol";

contract USDC_V2 is FiatTokenV2_1 {
    // 製作一個白名單
    mapping(address => bool) internal whiteList;
    bool public initializedv2;

    modifier onlyWhiteListed(address _account) {
        require(whiteList[_account] == true, "you are not in the whitelist");
        _;
    }

    // initialized
    function initializedV2() external {
        require(initializedv2 == false, "already initialized");
        initializedv2 = true;
    }

    // 新增用戶到白名單中
    function addWhiteList(address user) external onlyOwner {
        whiteList[user] = true;
    }

    // 檢查用戶是否在白名單中
    function isWhiteListed(address user) external view returns (bool) {
        return whiteList[user];
    }

    // 只有白名單內的地址可以轉帳
    function transfer(
        address to,
        uint256 amount
    )
        external
        override(FiatTokenV1, IERC20)
        onlyWhiteListed(msg.sender)
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    // 白名單內的地址可以無限 mint token
    function mint(uint256 amount) external onlyWhiteListed(msg.sender) {
        totalSupply_ += amount;
        balances[msg.sender] += amount;
    }

    function balanceOf(
        address account
    ) external view override(FiatTokenV1, IERC20) returns (uint256) {
        return balances[account];
    }

    function totalSupply()
        external
        view
        override(FiatTokenV1, IERC20)
        returns (uint256)
    {
        return totalSupply_;
    }
}
