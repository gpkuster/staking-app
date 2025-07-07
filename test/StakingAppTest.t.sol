// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {
    StakingToken stakingToken;
    StakingApp stakingApp;

    // StakingToken parameters
    string name_ = "Staking token";
    string symbol_ = "STK";

    // StakingApp parameters
    address owner_ = vm.addr(1);
    uint256 stakingPeriod_ = 1 days;
    uint256 fixedStakingAmount_ = 10;
    uint256 rewardPerPeriod_ = 1 ether;

    address randomUser = vm.addr(2);

    function setUp() external {
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp =
            new StakingApp(address(stakingToken), owner_, fixedStakingAmount_, stakingPeriod_, rewardPerPeriod_);
    }

    // Contract deployment
    function testStakingTokenDeployHappyPath() external view {
        //then
        assert(address(stakingToken) != address(0));
    }

    function testStakingAppDeployHappyPath() external view {
        //then
        assert(address(stakingApp) != address(0));
    }

    // Owner functionality
    function testShouldRevertIfNotOwnerChangingStakingPeriod() external {
        //given
        uint256 newStakingPeriod_ = 1;

        //then
        vm.expectRevert();

        //when
        stakingApp.changeStakingPeriod(newStakingPeriod_);
    }

    function testShouldChangeStakingPeriod() external {
        //given
        vm.startPrank(owner_);
        uint256 newStakingPeriod_ = 1;

        //when
        stakingApp.changeStakingPeriod(newStakingPeriod_);

        //then
        assert(stakingApp.stakingPeriod() == newStakingPeriod_);
        vm.stopPrank();
    }

    function testShouldRevertIfNotOwnerChangingStakingAmount() external {
        //given
        uint256 newStakingAmount_ = 1;

        //then
        vm.expectRevert();

        //when
        stakingApp.changeStakingAmount(newStakingAmount_);
    }

    function testShouldChangeStakingAmount() external {
        //given
        vm.startPrank(owner_);
        uint256 newStakingAmount_ = 1;

        //when
        stakingApp.changeStakingAmount(newStakingAmount_);

        //then
        assert(stakingApp.stakingPeriod() == newStakingAmount_);
        vm.stopPrank();
    }

    function testShouldNotTransferfEtherIfSenderIsNotOwner() external {
        //given
        vm.startPrank(randomUser);
        vm.deal(randomUser, 1 ether);
        uint256 etherValue = 1 ether;

        //when
        uint256 balanceBefore = address(stakingApp).balance;
        (bool success,) = address(stakingApp).call{value: etherValue}("");
        uint256 balanceAfter = address(stakingApp).balance;

        //then
        assert(!success);
        assert(balanceAfter - balanceBefore == 0);
    }

    function testContractReceivesEtherHappyPath() external {
        //given
        vm.startPrank(owner_);
        vm.deal(owner_, 1 ether);
        uint256 etherValue = 1 ether;

        //when
        uint256 balanceBefore = address(stakingApp).balance;
        (bool success,) = address(stakingApp).call{value: etherValue}("");
        uint256 balanceAfter = address(stakingApp).balance;

        //then
        assert(success);
        assert(balanceAfter - balanceBefore == etherValue);
    }

    // Deposit Function Testing
    function testDepositTokensHappyPath() external {
        //given
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodBefore = stakingApp.elapsedPeriod(randomUser);
        // allow _spender to withdraw from your account, multiple times, up to the _value amount
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount_);

        //when
        stakingApp.depositTokens();

        //then
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsedPeriodAfter = stakingApp.elapsedPeriod(randomUser);
        assert(userBalanceAfter - userBalanceBefore == fixedStakingAmount_);
        assert(elapsedPeriodBefore == 0);
        assert(elapsedPeriodAfter == block.timestamp);

        vm.stopPrank();
    }

    function testDepositTokensTwiceShouldRevert() external {
        //given
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        // allow _spender to withdraw from your account, multiple times, up to the _value amount
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount_);

        stakingApp.depositTokens();

        //then
        vm.expectRevert("User already deposited");

        //when
        stakingApp.depositTokens();

        vm.stopPrank();
    }

    // Withdraw Function Testing
    function testWithdrawTokensHappyPath() external {
        //given
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);

        uint256 initialUserBalance = stakingApp.userBalance(randomUser);
        // allow _spender to withdraw from your account, multiple times, up to the _value amount
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount_);

        stakingApp.depositTokens();
        uint256 userBalanceAfterDeposit = stakingApp.userBalance(randomUser);
        uint256 userTokensBeforeWithdrawal = IERC20(stakingToken).balanceOf(randomUser);

        //when
        stakingApp.withdrawTokens();
        uint256 userBalanceAfterWithdrawal = stakingApp.userBalance(randomUser);
        uint256 userTokensAfterWithdrawl = IERC20(stakingToken).balanceOf(randomUser);

        //then
        assertEq(initialUserBalance, 0);
        assertEq(userBalanceAfterDeposit, fixedStakingAmount_);
        assertEq(userBalanceAfterWithdrawal, 0);
        assertEq(userTokensBeforeWithdrawal, 0);
        assertEq(userTokensAfterWithdrawl, 10);

        vm.stopPrank();
    }

    // Claim Function Testing
    function testClaimRewardHappyPath() external {
        //given
        uint256 initialAppBalance = 2 ether;
        vm.deal(address(stakingApp), initialAppBalance);

        vm.startPrank(randomUser);
        uint256 etherBalanceBeforeClaiming = address(randomUser).balance;

        stakingToken.mint(fixedStakingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount_);
        stakingApp.depositTokens();

        vm.warp(block.timestamp + stakingPeriod_ + 1);

        //when
        stakingApp.claimReward();

        uint256 etherBalanceAfterClaiming = address(randomUser).balance;

        //then
        assertEq(etherBalanceAfterClaiming - etherBalanceBeforeClaiming, rewardPerPeriod_);
        assertEq(address(stakingApp).balance, initialAppBalance - etherBalanceAfterClaiming);
        vm.stopPrank();
    }

    function testShouldRevertIfUserIsNotStaking() external {
        //given
        vm.prank(randomUser);

        //then
        vm.expectRevert("Not staking");

        //when
        stakingApp.claimReward();

        vm.stopPrank();
    }

    function testShouldRevertIfNotEnoughElapsedPeriod() external {
        //given
        vm.startPrank(randomUser);

        stakingToken.mint(fixedStakingAmount_);
        IERC20(stakingToken).approve(address(stakingApp), fixedStakingAmount_);
        stakingApp.depositTokens();

        //then
        vm.expectRevert("Can't claim reward yet");

        //when
        stakingApp.claimReward();

        vm.stopPrank();
    }
}
