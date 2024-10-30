# Deployment of NTT Token

This describes the process for deploying a Native Token Transfer (NTT) token. An NTT token is an ERC20 Token with a couple of functions added to its [interface](https://github.com/wormhole-foundation/example-native-token-transfers/blob/main/evm/src/interfaces/INttToken.sol) to make it compatible with the wormhole protocol:

## 1. Install the Native Token Transfers CLI

Pre-requisites:

* Install [Foundry](https://book.getfoundry.sh/getting-started/installation)

* Install [Bun](https://bun.sh/)

Install the NTT CLI:

```bash
 curl -fsSL https://raw.githubusercontent.com/wormhole-foundation/example-native-token-transfers/main/cli/install.sh | bash
```

Verify the NTT CLI is installed:

```bash
 ntt --version
```
## 2. Deploy the Token Contract:

Clone the [Token Contract](https://github.com/wormhole-foundation/example-ntt-token) repo:

```bash
 git clone https://github.com/wormhole-foundation/example-ntt-token.git
```

Deploy the [PeerToken](https://github.com/wormhole-foundation/example-ntt-token/blob/main/src/PeerToken.sol) Contract:

```sh
forge create --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> src/PeerToken.sol:PeerToken --constructor-args <TOKEN_NAME> <TOKEN_SIMBOL> <MINTER_ADDRESS> <OWNER_ADDRESS>
```
For easier customization, you can define and export the variables first:

```sh
export RPC_URL="<rpc_url>"
export PRIVATE_KEY="<private_key>"
export TOKEN_NAME="<token_name>"
export TOKEN_SYMBOL="<token_symbol>"
export MINTER_ADDRESS="<minter_address>"
export OWNER_ADDRESS="<owner_address>"

forge create --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" src/PeerToken.sol:PeerToken --constructor-args "$TOKEN_NAME" "$TOKEN_SYMBOL" "$MINTER_ADDRESS" "$OWNER_ADDRESS"
```


Note: *A Smart Contract is needed on each chain we want to support. So the deployment process should be repeated for each chain.*

## 3. Mint Tokens to Verify Deployment

```bash
cast send <TOKEN_SMARTCONTRACT_ADDRESS> "mint(address, uint256)" <MINT_TO_ADDRESS> <AMOUNT_TO_MINT> --private-key <PRIVATE_KEY> --rpc-url <RPC_URL>
```

or

```bash
export TOKEN_SMARTCONTRACT_ADDRESS="<token_smartcontract_address>"
export MINT_TO_ADDRESS="<address_to_mint_to>"
export AMOUNT_TO_MINT="<amount_to_mint>"

cast send "$TOKEN_SMARTCONTRACT_ADDRESS" "mint(address, uint256)" "$MINT_TO_ADDRESS" "$AMOUNT_TO_MINT" --private-key "$PRIVATE_KEY" --rpc-url "$RPC_URL"
```

## 4. Set Token Minter to NTT Manager

After the NTT Manager has been deployed, it is necessary to grant it minting rights:

```bash
cast send <TOKEN_SMARTCONTRACT_ADDRESS> "setMinter(address)" <NTT_MANAGER_ADDRESS> --private-key <PRIVATE_KEY> --rpc-url <RPC_URL>
```
or

```bash
export TOKEN_SMARTCONTRACT_ADDRESS="<token_smartcontract_address>"
export NTT_MANAGER_ADDRESS="<ntt_manager_address>"
export PRIVATE_KEY="private_key"
export RPC_URL="<rpc_url>"

cast send "$TOKEN_SMARTCONTRACT_ADDRESS" "setMinter(address)" "$NTT_MANAGER_ADDRESS" --private-key "$PRIVATE_KEY" --rpc-url "$RPC_URL"
```







