"use client";

import React, { Suspense } from "react";
import dynamic from "next/dynamic";
import "./page.css";
import WormholeConnect, { WormholeConnectConfig, nttRoutes } from "@wormhole-foundation/wormhole-connect";

// Disable SSR for WormholeConnect
const WormholeConnectNoSSR = dynamic(() => Promise.resolve(WormholeConnect), { ssr: false });

// Synchronous wormholeConfig setup
const wormholeConfig: WormholeConnectConfig = {
  network: "Testnet",
  chains: ["Sepolia", "ArbitrumSepolia"],
  rpcs: {
    Sepolia: "https://rpc.ankr.com/eth_sepolia",
    BaseSepolia: "https://base-sepolia-rpc.publicnode.com",
    ArbitrumSepolia: "https://sepolia-rollup.arbitrum.io/rpc",
  },
  routes: nttRoutes({
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
  tokensConfig: {
    NTTTTsep: {
      key: "NTTTTsep",
      symbol: "NTTTT",
      nativeChain: "Sepolia",
      displayName: "NTTTT (Sep)",
      tokenId: {
        chain: "Sepolia",
        address: "0xA0e4C6FA5dFc8d68C06C4Caefa0439B4dFC2F697",
      },
      coinGeckoId: "test",
      icon: "https://wormhole.com/token.png",
      color: "#00C3D9",
      decimals: 18,
    },
    NTTTTsol: {
      key: "NTTTTsol",
      symbol: "NTTTT",
      nativeChain: "ArbitrumSepolia",
      displayName: "NTTTT (ArbitrumSepolia)",
      tokenId: {
        chain: "ArbitrumSepolia",
        address: "0x183Ae4A056566803a10d7FDF85b723FcCd54b926",
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
  text: "#F9FBFF",
  textSecondary: "#F9FBFF",
  error: "#FF8863",
  success: "#83ff8c",
  badge: "#385183",
  font: "Century Gothic,CenturyGothic,AppleGothic,sans-serif",
};

const Connect = () => {
  return (
    <>
      <div className="text-center mt-0 bg-base-300 px-10 pt-10 pb-8">
        <h1 className="text-4xl my-0">Entity Surge + Wormhole Connect</h1>
        <p className="text-neutral">Transfer NTT-enabled Tokens Across Supported Chains.</p>
      </div>
      <Suspense fallback={<div>Loading Wormhole Connect...</div>}>
        <div className="wormhole-wrapper">
          <WormholeConnectNoSSR config={wormholeConfig} theme={theme} />
        </div>
      </Suspense>
    </>
  );
};

export default Connect;
