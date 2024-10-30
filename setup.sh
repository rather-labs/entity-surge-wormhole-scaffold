#!/bin/zsh

NETWORK_1=arbitrum
NETWORK_1U=Arbitrum
NETWORK_2=polygon
NETWORK_2U=Polygon

echo "Deploying Launchpad token on $NETWORK_2U chain."

read TOKEN_2 < <(yarn deploy --tags Launchpad --network $NETWORK_2 | grep -E 'deploying "LaunchpadToken"|reusing "LaunchpadToken"' | sed -E 's/.*(deployed at|at) ([^ ]+).*/\2/' | head -n 1)

echo $TOKEN_2

echo "Deploying Launchpad token on $NETWORK_1U chain."

read TOKEN_1 < <(yarn deploy --tags Launchpad --network $NETWORK_1 | grep -E 'deploying "LaunchpadToken"|reusing "LaunchpadToken"' | sed -E 's/.*(deployed at|at) ([^ ]+).*/\2/' | head -n 1)

echo $TOKEN_1

echo "Setting up Wormhole NTT for Launchpad tokens ($TOKEN_1 / $TOKEN_2)."

cd wh-token
yarn install
rm -f deployment.json
ntt init Mainnet
ntt add-chain $NETWORK_1U --latest --mode burning --token $TOKEN_1 --skip-verify
ntt add-chain $NETWORK_2U --latest --mode burning --token $TOKEN_2 --skip-verify
cp deployment.json ../packages/nextjs/contracts/deployment.json
cp deployment.json ../packages/hardhat/deploy/deployment.json
cd ..
yarn deploy --tags SetMinter --network $NETWORK_1
yarn deploy --tags SetMinter --network $NETWORK_2