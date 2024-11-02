"use client";

import "./page.css";
import WormholeConnect, { nttRoutes } from "@wormhole-foundation/wormhole-connect";

//import deployment from "~~/deployments/deployment.json";

/* export const metadata = getMetadata({
  title: "Entity Surge + Wormhole Connect",
  description: "Manage Cross-Chain Transfers with Wormhole's NTT Protocol",
}); */

const wormholeConfig = {
  network: "Testnet", // from deployment.json of the NTT deployment directory
  //networks: ['sepolia', 'ArbitrumSepolia', 'BaseSepolia', 'Avalanche'], // from https://github.com/wormhole-foundation/wormhole-connect/blob/development/wormhole-connect/src/config/testnet/chains.ts#L170
  chains: ["Sepolia", "ArbitrumSepolia"],
  // tokens: ['FTTsep', 'FTTsol'],  // this will limit the available tokens that can be transferred to the other chain
  // routes: ['nttManual'], // this will limit the available routes - from https://github.com/wormhole-foundation/wormhole-connect/blob/d7a6b67b18db2c8eb4a249d19ef77d0174deffbe/wormhole-connect/src/config/types.ts#L70
  rpcs: {
    Sepolia: "https://rpc.ankr.com/eth_sepolia",
    BaseSepolia: "https://base-sepolia-rpc.publicnode.com",
    ArbitrumSepolia: "https://sepolia-rollup.arbitrum.io/rpc",
  },
  routes: [
    ...nttRoutes({
      tokens: {
        NTTTT: [
          {
            chain: "Sepolia",
            manager: "0xE2A2bedF4E404A1CCE742AcC08abBedf2c51C4dF",
            token: "0xA0e4C6FA5dFc8d68C06C4Caefa0439B4dFC2F697",
            transceiver: [
              {
                address: "0xccd630AD8030694eDe09d90991edff96ADcdBB61",
                type: "wormhole",
              },
            ],
          },
          {
            chain: "ArbitrumSepolia",
            manager: "0xFb9d0D37aEe1706A8c8E722e8Bc843fb48978969",
            token: "0x183Ae4A056566803a10d7FDF85b723FcCd54b926",
            transceiver: [
              {
                address: "0x1a46812208707D009D1E871453Fb62d76d118A0f",
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
    NTTTTsep: {
      key: "NTTTTsep",
      symbol: "NTTTT",
      nativeChain: "Sepolia", // will be shown as native only on this chain, otherwise as "Wormhole wrapped"
      displayName: "NTTTT (Sep)", // name that is displayed in the Route
      tokenId: {
        chain: "Sepolia",
        address: "0xA0e4C6FA5dFc8d68C06C4Caefa0439B4dFC2F697", // token address
      },
      coinGeckoId: "test",
      icon: "https://wormhole.com/token.png",
      color: "#00C3D9",
      decimals: 18,
    },
    NTTTTsol: {
      key: "NTTTTsol",
      symbol: "NTTTT",
      nativeChain: "ArbitrumSepolia", // will be shown as native only on this chain, otherwise as "Wormhole wrapped"
      displayName: "NTTTT (ArbitrumSepolia)", // name that is displayed in the Route
      tokenId: {
        chain: "ArbitrumSepolia",
        address: "0x183Ae4A056566803a10d7FDF85b723FcCd54b926", // token address
      },
      coinGeckoId: "test",
      icon: "https://wormhole.com/token.png",
      color: "#00C3D9",
      decimals: 18,
    },
  },
};

const theme = {
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
