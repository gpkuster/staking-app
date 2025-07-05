// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    string name_ = "Staking token";
    string symbol_ = "STK";
    address randomUser = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name_, symbol_);
    }

    function testStakingTokenMintsCorrectly() public {
        uint256 amount_ = 1 ether;
        vm.startPrank(randomUser);
        uint256 balanceBeforeMint_ = IERC20(address(stakingToken)).balanceOf(randomUser);
        stakingToken.mint(amount_);
        uint256 balanceAfterMint_ = IERC20(address(stakingToken)).balanceOf(randomUser);
        vm.stopPrank();
        assert((balanceAfterMint_ - balanceBeforeMint_) == amount_);
    }
}
