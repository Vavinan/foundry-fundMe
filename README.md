# Foundry FundMe

This repository is a simple FundMe dApp example built with Foundry.

The contract accepts ETH deposits only when the deposit is worth at least $5 USD, using a Chainlink ETH/USD price feed. The contract owner can withdraw the funds, and the contract supports both `withdraw()` and a gas-optimized `cheaperWithdraw()`.

## Project Overview

- `src/FundMe.sol` - Main funding contract
- `src/PriceConverter.sol` - Library to convert ETH to USD using Chainlink price feeds
- `script/DeployFundMe.s.sol` - Deployment script that uses `HelperConfig` to select the correct price feed address
- `script/HelperConfig.s.sol` - Local vs live network configuration, deploys a mock price feed for Anvil
- `test/unit/FundMeTest.t.sol` - Unit tests for funding and withdrawal behavior

## Requirements

- Foundry installed
- `forge`, `cast`, and `anvil` available in your PATH

## Setup

If the repository dependencies are not already installed, run:

```bash
forge install
```

Then build the project:

```bash
forge build
```

## Run Tests

Run the full test suite:

```bash
forge test
```

Run only the FundMe unit tests:

```bash
forge test --match-contract FundMeTest
```

## Local Development

Start a local node with Anvil:

```bash
anvil
```

Deploy locally using the script; `HelperConfig` deploys a mock ETH/USD feed automatically on Anvil:

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe --broadcast --rpc-url http://127.0.0.1:8545 --private-key <PRIVATE_KEY>
```

## Deploy to Sepolia (or another network)

Use a real RPC URL and private key. The deployment script will choose the correct price feed address for Sepolia.

```bash
forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## Contract Behavior

- `fund()` requires at least `MINIMUM_USD` worth of ETH, calculated using the Chainlink price feed
- `withdraw()` transfers the entire contract balance to the owner and resets funders
- `cheaperWithdraw()` performs the same action using a more gas-efficient loop
- `fallback()` and `receive()` both call `fund()` so sending ETH directly also funds the contract

## Notes

- `HelperConfig` returns a live Chainlink feed address on Sepolia and Mainnet
- For local testing, it deploys a mock `MockETHUSDAggregator` with an initial price
- The contract stores funders and their funded amounts in mappings and arrays

## Useful Commands

```bash
forge fmt
forge test
forge build
anvil
```

## References

- Foundry docs: https://book.getfoundry.sh/
- Chainlink price feeds: https://docs.chain.link/data-feeds/
