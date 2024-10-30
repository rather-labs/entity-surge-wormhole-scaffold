"use client";

import "./page.css";
import WormholeConnect, { nttRoutes } from "@wormhole-foundation/wormhole-connect";
import type { WormholeConnectConfig, WormholeConnectTheme } from "@wormhole-foundation/wormhole-connect";
import deployment from "~~/contracts/deployment.json";

/* export const metadata = getMetadata({
  title: "Entity Surge + Wormhole Connect",
  description: "Manage Cross-Chain Transfers with Wormhole's NTT Protocol",
}); */

const wormholeConfig: WormholeConnectConfig = {
  network: "Mainnet", // from deployment.json of the NTT deployment directory
  //networks: ['sepolia', 'ArbitrumSepolia', 'BaseSepolia', 'Avalanche'], // from https://github.com/wormhole-foundation/wormhole-connect/blob/development/wormhole-connect/src/config/testnet/chains.ts#L170
  chains: ["Arbitrum", "Optimism"],
  // tokens: ['FTTsep', 'FTTsol'],  // this will limit the available tokens that can be transferred to the other chain
  // routes: ['nttManual'], // this will limit the available routes - from https://github.com/wormhole-foundation/wormhole-connect/blob/d7a6b67b18db2c8eb4a249d19ef77d0174deffbe/wormhole-connect/src/config/types.ts#L70
  rpcs: {
    Optimism: "https://mainnet.optimism.io",
    Arbitrum: "https://arb1.arbitrum.io/rpc",
  },

  routes: [
    ...nttRoutes({
      tokens: {
        LNCH: [
          {
            chain: "Arbitrum",
            manager: deployment.chains.Arbitrum.manager,
            token: deployment.chains.Arbitrum.token,
            transceiver: [
              {
                address: deployment.chains.Arbitrum.transceivers.wormhole.address,
                type: "wormhole",
              },
            ],
          },
          {
            chain: "Optimism",
            manager: deployment.chains.Optimism.manager,
            token: deployment.chains.Optimism.token,
            transceiver: [
              {
                address: deployment.chains.Optimism.transceivers.wormhole.address,
                type: "wormhole",
              },
            ],
          },
        ],
      },
    }),
    /* other routes */
  ],
  tokensConfig: {
    LNCHopt: {
      key: "LNCHopt",
      symbol: "LNCH",
      nativeChain: "Optimism", // will be shown as native only on this chain, otherwise as "Wormhole wrapped"
      displayName: "LNCH (OP)", // name that is displayed in the Route
      tokenId: {
        chain: "Optimism",
        address: deployment.chains.Optimism.token, // token address
      },
      coinGeckoId: "test",
      icon: "https://wormhole.com/token.png",
      color: "#00C3D9",
      decimals: 18,
    },

    LNCHarb: {
      key: "LNCHarb",
      symbol: "LNCH",
      nativeChain: "Arbitrum", // will be shown as native only on this chain, otherwise as "Wormhole wrapped"
      displayName: "LNCH (ARB)", // name that is displayed in the Route
      tokenId: {
        chain: "Arbitrum",
        address: deployment.chains.Arbitrum.token, // token address
      },
      coinGeckoId: "test",
      icon: "https://wormhole.com/token.png",
      color: "#00C3D9",
      decimals: 18,
    },
  },
};

const theme: WormholeConnectTheme = {
  mode: "dark",
  primary: "#077f75",
  secondary: "#044c46",
  text: "#F9FBFF", // Neutral content color for main text
  textSecondary: "#F9FBFF", // Darker tone for secondary text
  error: "#FF8863",
  success: "#83ff8c",
  badge: "#385183", // Using info color for badges
  font: "Century Gothic,CenturyGothic,AppleGothic,sans-serif", // Custom font for text
};

const Connect = () => {
  return (
    <>
      <div className="text-center mt-0 bg-base-300 px-10 pt-10 pb-8">
        <h1 className="text-4xl my-0">Entity Surge + Wormhole Connect</h1>
        <p className="text-neutral">Transfer NTT-enabled Tokens Accross Supported Chains.</p>
      </div>
      <div className="wormhole-wrapper">
        <WormholeConnect config={wormholeConfig} theme={theme} />
      </div>
    </>
  );
};

export default Connect;
