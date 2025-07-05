// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// Staking fixed amount (10 tokens)
// Staking reward period (1 dia) - cada que pase podrá recoger rewards. Una vez lo retire ya no podra
//
contract StakingApp is Ownable {
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewardPerPeriod;

    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public elapsedPeriod;

    event ChangeStakingPeriod(uint256 newStakingPeriod_);
    event DepositTokens(address userAddress_, uint256 depositAmount_);
    event WithdrawTokens(address userAddress_, uint256 withdrawAmount_);
    event EtherSent(uint256 amount_);

    // We can use onlyOwner() without defining it
    constructor(address _stakingToken, address _initialOwner, uint256 _stakingPeriod, uint256 _rewardPerPeriod)
        Ownable(_initialOwner)
    {
        stakingToken = _stakingToken;
        stakingPeriod = _stakingPeriod;
        rewardPerPeriod = _rewardPerPeriod;
    }

    function depositTokens() external {
        require(userBalance[msg.sender] == 0, "User already deposited");

        IERC20(stakingToken).transferFrom(msg.sender, address(this), fixedStakingAmount);
        userBalance[msg.sender] += fixedStakingAmount;
        elapsedPeriod[msg.sender] = block.timestamp;

        emit DepositTokens(msg.sender, fixedStakingAmount);
    }

    function withdrawTokens() external {
        // CEI pattern not needed here because we are not using fallback functions (in which mailitious code could be executed), but it is better to use it
        // We could be using a malicious token...
        // Also, in ERC-721, there is something similar to receive functions
        uint256 _userBalance = userBalance[msg.sender];
        userBalance[msg.sender] = 0;
        IERC20(stakingToken).transfer(msg.sender, _userBalance);
    }

    function claimReward() external {
        require(userBalance[msg.sender] == fixedStakingAmount, "Not staking");

        uint256 _elapsePeriod = block.timestamp - elapsedPeriod[msg.sender];
        require(_elapsePeriod >= stakingPeriod, "Can't claim reward yet");

        elapsedPeriod[msg.sender] = block.timestamp;

        (bool success,) = msg.sender.call{value: rewardPerPeriod}("");
        require(success, "Transfer failed");
    }

    // function feedContract() external payable onlyOwner {}

    receive() external payable onlyOwner {
        emit EtherSent(msg.value);
    }

    function changeStakingPeriod(uint256 newStakingPeriod) external onlyOwner {
        stakingPeriod = newStakingPeriod;
        emit ChangeStakingPeriod(newStakingPeriod);
    }

    function changeStakingAmount(uint256 newStakingAmount) external onlyOwner {
        stakingPeriod = newStakingAmount;
        emit ChangeStakingPeriod(newStakingAmount);
    }
}
