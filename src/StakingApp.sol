// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StakingApp is Ownable {

    address public stakingToken;

    // We can use onlyOwner() without defining it
    constructor(address _stakingToken, address _initialOwner) Ownable(_initialOwner) {
        stakingToken = _stakingToken;
    }

    


}