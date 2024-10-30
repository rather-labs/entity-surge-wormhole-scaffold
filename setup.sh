#!/bin/zsh

echo "Deploying Launchpad token on Arbitrum chain."

read TOKEN_1 < <(yarn deploy --network arbitrum | grep -E 'deploying "LaunchpadToken"|reusing "LaunchpadToken"' | sed -E 's/.*(deployed at|at) ([^ ]+).*/\2/' | head -n 1)

echo "Deploying Launchpad token on Optimism chain."

read TOKEN_2 < <(yarn deploy --network optimism | grep -E 'deploying "LaunchpadToken"|reusing "LaunchpadToken"' | sed -E 's/.*(deployed at|at) ([^ ]+).*/\2/' | head -n 1)

echo "Setting up Wormhole NTT for Launchpad tokens ($TOKEN_1 / $TOKEN_2)."

cd wh-token && rm deployment.json && ntt init Mainnet && ntt add-chain Optimism --latest --mode burning --token $TOKEN_1 --skip-verify && ntt add-chain Arbitrum --latest --mode burning --token $TOKEN_2 --skip-verify && cp deployment.json ../packages/nextjs/contracts/deployment.json && cp deployment.json ../packages/hardhat/deploy/deployment.json || cd ..
