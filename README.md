# 💰 Staking App (Foundry)

This is a simple staking application built with Solidity and Foundry. It allows users to stake a fixed amount of ERC20 tokens and receive ETH rewards after a defined period. The project includes a custom ERC20 token (`StakingToken`) and a staking contract (`StakingApp`).

## ✨ Features

- 🔒 Fixed staking amount per user
- ⏱️ One-time reward claim after a reward period
- 🛠️ Owner can adjust staking parameters
- 💸 Users receive ETH rewards
- 🧪 Includes test token with minting function

## 📁 Project Structure

- `src/`: Contains the smart contracts
- `test/`: Foundry tests (if any)
- `.gitignore`: Ignores build artifacts and dependencies
- `foundry.toml`: Foundry configuration file

## 🚀 Getting Started

To use or build this project, follow these steps:

1. 📥 Clone the repository:
```
git clone https://github.com/gpkuster/staking-app.git
cd staking-app
```

2. 📦 Install dependencies:
```
forge install foundry-rs/forge-std
forge install OpenZeppelin/openzeppelin-contracts
```
3. 🧱 Compile the contracts:
```
forge build
```
4. 🧪 (Optional) Run tests:
```
forge test
```
5. 📊 (Optional) Check LCOV report:
```
genhtml lcov.info --output-directory coverage
open coverage/index.html
```
## ⚠️ Notes

- The `lib/` folder is **not included** in the repository to keep it clean. You must run `forge install` to download dependencies like OpenZeppelin.
- Make sure you have Foundry installed: https://book.getfoundry.sh/

## 🪪 License

MIT
