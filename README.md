## Entity Surge + Wormhole Native Token Transfer and Wormhole Connect

Entity's submission to the Wormhole SIGMA sprint aims to extend the functionality of its cross-chain Launchpad, allowing seamless transfer and deployment of tokens across multiple EVM-compatible chains, specifically Base, Arbitrum, Optimism, and Ethereum. This integration enhances interoperability within the ecosystem, enabling users to create, move, and manage tokens beyond a single blockchain.

The primary objectives for this submission are:

1. Cross-Chain Token Transfer: Utilize Wormhole's cross-chain messaging to facilitate Native Token Transfer (NTT), enabling tokens to bridge seamlessly between supported networks.
2. Enhanced Token Accessibility: Allow users to move their tokens easily, making them accessible across multiple chains while keeping the Launchpad's token architecture flexible.
3. Token Distribution via Ticket Raffle (Entity Surge): Leverage Entity's cross-chain launchpad to distribute tokens from various projects through its tickets raffle system, broadening token access and user engagement.

#### Full walkthrough [video here](https://drive.google.com/file/d/1kh0fnQaSrdNz5Ib0-h9bvmrpJfxf9kNt/view?usp=sharing).

## Setup and Configuration of NTT Tokens on Entity Launchpad

The `setup.sh` script provides an automated, one-step process to deploy and configure Native Token Transfer tokens on Entity's Launchpad across two networks, specifically designed for use with Wormhole's cross-chain messaging. This script is located at the root of the repository. While this script focuses only on 2 networks, it is possible to seamlessly expand to more than that as long as these are the supported NTT chains.

#### Requirements
Ensure you have the following installed and configured on your system:
- **Zsh**: This script uses the Z shell (`#!/bin/zsh`) as the interpreter.
- **Yarn**: Used for deployment commands and package installation.
- **Wormhole NTT CLI (`ntt`)**: Required to manage the cross-chain token setup.

### Script Execution Steps
To execute the `setup.sh` script:
1. Open your terminal and navigate to the root directory of the repository.
2. Run the script with the following command:
   ```bash
   ./setup.sh
   ```

#### **Script Details and Workflow**

The `setup.sh` script performs the following key operations:

1. **Set Network Variables**
   - The script starts by defining two networks where tokens will be deployed:
     - `NETWORK_1` is set to "Arbitrum."
     - `NETWORK_2` is set to "Polygon."

2. **Deploy Launchpad Token on Polygon**
   - The script echoes the action and then executes the deployment:
     ```bash
     read TOKEN_2 < <(yarn deploy --tags Launchpad --network $NETWORK_2 | grep -E 'deploying "LaunchpadToken"|reusing "LaunchpadToken"' | sed -E 's/.*(deployed at|at) ([^ ]+).*/\2/' | head -n 1)
     ```
   - This command deploys (or reuses) the `LaunchpadToken` contract on Polygon and captures the deployed address in the `TOKEN_2` variable.

3. **Deploy Launchpad Token on Arbitrum**
   - Similarly, the script echoes and deploys the Launchpad token on the Arbitrum network:
     ```bash
     read TOKEN_1 < <(yarn deploy --tags Launchpad --network $NETWORK_1 | grep -E 'deploying "LaunchpadToken"|reusing "LaunchpadToken"' | sed -E 's/.*(deployed at|at) ([^ ]+).*/\2/' | head -n 1)
     ```
   - This address is captured in the `TOKEN_1` variable.

4. **Configure Wormhole NTT for Cross-Chain Tokens**
   - The script then enters the `wh-token` directory, installs dependencies, and initializes Wormhole NTT configuration:
     ```bash
     cd wh-token
     yarn install
     rm -f deployment.json
     ntt init Mainnet
     ```
   - After initializing for the mainnet environment, the script sets up each chain for the tokens using the `ntt add-chain` command with burning mode for each network:
     ```bash
     ntt add-chain $NETWORK_1U --latest --mode burning --token $TOKEN_1 --skip-verify
     ntt add-chain $NETWORK_2U --latest --mode burning --token $TOKEN_2 --skip-verify
     ```
   - Finally, the NTT configuration is pushed, and the generated deployment file is copied to relevant directories for the Next.js and Hardhat installations to use:
     ```bash
     ntt push
     cp deployment.json ../packages/nextjs/contracts/deployment.json
     cp deployment.json ../packages/hardhat/deploy/deployment.json
     ```

5. **Set Minter for Each Network**
   - The script completes the setup by configuring the minter role on both networks:
     ```bash
     yarn deploy --tags SetMinter --network $NETWORK_1
     yarn deploy --tags SetMinter --network $NETWORK_2
     ```

#### Outputs
Upon successful execution, the script provides:
- Deployment addresses of the `LaunchpadToken` contract on both Polygon and Arbitrum.
- Configured `deployment.json` files in specified directories for application integration.
  
### Troubleshooting Tips
If any part of the script fails, ensure that:
- Dependencies are correctly installed (e.g., `yarn`, Wormhole NTT CLI).
- Network names (`NETWORK_1` and `NETWORK_2`) match the environments available in your setup.

If for any particular reason it is desired to deploy the NTT tokens manually, extended instructions are included in the [Native Token Transfer Deployment docs](./docs/native-token-deployment.md)

---

## How to use Next.js and Hardhat setup

This guide explains how to deploy Entity's Launchpad smart contracts across supported networks and configure the Next.js app to automatically pick up these contracts, ensuring the Launchpad functions seamlessly within the app.

#### Network Configuration for Smart Contract Deployment

1. **Configuring Networks**: The networks for deployment are configured in the `packages/hardhat/hardhat.config.ts` file. This file defines various network connections, including RPC URLs, private keys, and other configuration details.

2. **Deploying the Launchpad Smart Contracts**:
   - Use the following command to deploy the Launchpad smart contracts to a specified network:
     ```bash
     yarn deploy --network <NETWORK_NAME>
     ```
   - Replace `<NETWORK_NAME>` with the appropriate network identifier (e.g., `arbitrum`, `polygon`).
   - During deployment, the process will generate configuration files that the Next.js app reads to integrate with the deployed smart contracts automatically.

#### Configuring the Next.js App to Support Multiple Chains

1. **Supported Chains Configuration**:
   - In the Next.js app, `packages/nextjs/scaffold.config.ts` allows you to configure the app's supported chains, enabling the app to work with chains like Base, Arbitrum, Sepolia, and Ethereum.
   - This configuration defines which chains the app can interact with and allows users to connect and use the Launchpad across multiple networks.

2. **Automatic Integration with Deployed Smart Contracts**:
   - Once the smart contracts are deployed, the configuration files generated in `deployment.json` are used by the Next.js app to integrate with the deployed contracts automatically. No additional configuration is required to connect the app with the new deployments.

#### Setting Parameters for the Launchpad Smart Contract:

In `packages/hardhat/deploy/00_deploy_your_contract.ts`, you can configure essential parameters for the Launchpad smart contract. These parameters include settings for the randomization process, ticketing, and claim periods, which allow you to fine-tune the Launchpad's behavior:

- **publicKey** and **proof**: Used for the randomization process within the Launchpad.
- **launchpadTokensPerWinningTicket**: Specifies the number of tokens awarded per winning ticket.
- **ticketPrice**: Sets the price of a single ticket for the raffle.
- **ticketPaymentToken**: Defines the token used to pay for tickets.
- **launchpadToken**: The token deployed for the Launchpad.
- **nrWinningTickets**: Sets the number of tickets that will be selected as winners.
- **confirmationPeriodStartTime**: Defines the start time for the confirmation period.
- **winnerSelectionStartTime**: Specifies the start time for the winner selection process.
- **claimStartTime**: Sets the time at which winners can start claiming their prizes.

---

### Lottery Process Overview

The lottery process includes several stages, from ticket confirmation to winner selection and reward claiming:

1. **Ticket Allocation**: Administrators assign tickets to participants during an initial phase.
2. **Ticket Confirmation**: Users confirm tickets during a specified period by sending the required payment.
3. **Ticket Filtering**: Removes tickets from blacklisted users or unconfirmed ones.
4. **Winner Selection**: VRF-based randomness is used to select winners, ensuring fairness.
5. **NFT Distribution**: Winning tickets may grant an NFT, which users can claim post-lottery.
6. **Reward Claiming**: Winners claim tokens and/or NFTs.
7. **Post-Lottery Cleanup**: The contract resets any remaining tokens or refunds, transferring them to designated accounts if necessary.

Here is a step-by-step guide on the methods to be called in the smart contract to go through the full distribution process for Entity's Launchpad, from allocating tickets of the lottery to distributing rewards and final cleanup.

**Add Tickets**:
   - **Method**: `addTickets`
   - **Purpose**: Allocates tickets to participants. This can be done only by administrators.
   - **Parameters**: List of addresses and ticket quantities for each participant.

**Confirm Tickets**:
   - **Method**: `confirmTickets`
   - **Purpose**: Participants confirm their tickets during the designated period by making the required payment.
   - **Parameters**: Number of tickets being confirmed.

**Filter Tickets**:
   - **Method**: `filterTickets`
   - **Purpose**: Filters out any tickets associated with blacklisted addresses and removes unconfirmed tickets from eligibility.
   - **Timing**: This should be called after the "Confirmation Period" has ended.

**Shuffle Tickets**:
   - **Method**: `initShuffler`
   - **Purpose**: Uses the VRF proof and value to shuffle tickets randomly before winner selection.
   - **Parameters**: VRF proof and random value generated during the VRF process.

**Select Winners**:
   - **Method**: `selectWinners`
   - **Purpose**: Chooses winners from the eligible tickets based on the VRF-generated randomness, ensuring fair selection.
   - **Timing**: This should be called after the "Winner Selection Period" has started.

**Claim Rewards**:
   - **Method**: `claimLaunchpadTokens` and `claimNft`
   - **Purpose**: Winners can claim their rewards, which may include both tokens and NFTs, depending on the lottery setup.
   - **Parameters for `claimLaunchpadTokens`**: None (claim based on confirmed winning tickets).
   - **Parameters for `claimNft`**: None (mint an NFT representing winning ticket ownership).

**Refund for Non-Winning Tickets (Optional)**:
   - **Method**: `claimRefund`
   - **Purpose**: Allows participants to reclaim funds for tickets that didn't win or tickets that were overconfirmed.

### Randomness and Verifiability (VRF)

The Entity Launchpad smart contract uses a Verifiable Random Function (VRF) to ensure fair randomness, particularly for ticket shuffling and winner selection. Key aspects include:

- **Random Value Generation**: A cryptographically secure random value is generated for ticket shuffling and winner selection.
- **Verifiability**: The VRF's cryptographic proof is stored and can be verified by any user.
- **Non-Predictability**: The VRF input is based on unpredictable elements (e.g., block timestamp, confirmed ticket count).

**Risk Note**: VRF mitigates manipulation risks by ensuring public verification, which reduces potential influence on ticket shuffling or winner selection.

### NFT Minting and Distribution

The Launchpad's NFT module handles minting and distribution using the ERC721 standard.

- **Minting**: The `claimNft` function mints an NFT for winners, with metadata capturing the number of winning tickets.
- **Distribution**: Eligible winners use the `claimNft` function to receive their NFTs.

NFTs track the association between users and their winning tickets, enabling an added reward layer in the Launchpad.
