"use client";

import "./page.css";
import WormholeConnect, { nttRoutes } from "@wormhole-foundation/wormhole-connect";
import deployment from "~~/contracts/deployment.json";

/* export const metadata = getMetadata({
  title: "Entity Surge + Wormhole Connect",
  description: "Manage Cross-Chain Transfers with Wormhole's NTT Protocol",
}); */

const wormholeConfig = {
  network: "Mainnet", // from deployment.json of the NTT deployment directory
  //networks: ['sepolia', 'ArbitrumSepolia', 'BaseSepolia', 'Avalanche'], // from https://github.com/wormhole-foundation/wormhole-connect/blob/development/wormhole-connect/src/config/testnet/chains.ts#L170
  chains: Object.keys(deployment.chains),
  // tokens: ['FTTsep', 'FTTsol'],  // this will limit the available tokens that can be transferred to the other chain
  // routes: ['nttManual'], // this will limit the available routes - from https://github.com/wormhole-foundation/wormhole-connect/blob/d7a6b67b18db2c8eb4a249d19ef77d0174deffbe/wormhole-connect/src/config/types.ts#L70
  rpcs: {
    Polygon: "https://polygon.llamarpc.com",
    Arbitrum: "https://arb1.arbitrum.io/rpc",
    Optimism: "https://mainnet.optimism.io",
  },

  routes: [
    ...nttRoutes({
      tokens: {
        LNCH: Object.keys(deployment.chains).map(chain => ({
          chain,
          manager: deployment.chains[chain].manager,
          token: deployment.chains[chain].token,
          transceiver: [
            {
              address: deployment.chains[chain].transceivers.wormhole.address,
              type: "wormhole",
            },
          ],
        })),
      },
    }),
    /* other routes */
  ],
  tokensConfig: Object.fromEntries(
    Object.keys(deployment.chains).map(chain => [
      "LNCH-" + chain,
      {
        key: "LNCH-" + chain,
        symbol: "LNCH",
        nativeChain: chain,
        displayName: `LNCH (${chain})`,
        tokenId: {
          chain,
          address: deployment.chains[chain].token,
        },
        coinGeckoId: "test",
        icon: "https://wormhole.com/token.png",
        color: "#00C3D9",
        decimals: 18,
      },
    ]),
  ),
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
