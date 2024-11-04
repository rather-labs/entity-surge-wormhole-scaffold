// This file exports a utility function used to add the hosted version of Connect to a webpage
import type { WormholeConnectConfig, WormholeConnectTheme } from "@wormhole-foundation/wormhole-connect";

export interface HostedParameters {
  config?: WormholeConnectConfig;
  theme?: WormholeConnectTheme;
  version?: string;
  cdnBaseUrl?: string;
}

const CONNECT_VERSION = "1.0.0";

export function wormholeConnectHosted(parentNode: HTMLElement, params: HostedParameters = {}) {
  /* @ts-ignore */
  window.__CONNECT_CONFIG = params.config;
  /* @ts-ignore */
  window.__CONNECT_THEME = params.theme;

  const connectRoot = document.createElement("div");
  connectRoot.id = "wormhole-connect";

  const version = params.version ?? CONNECT_VERSION;
  const baseUrl = params.cdnBaseUrl ?? `https://cdn.jsdelivr.net/npm/@wormhole-foundation/wormhole-connect@${version}`;

  const script = document.createElement("script");
  script.setAttribute("src", `${baseUrl}/dist/main.js`);
  script.setAttribute("type", "module");

  parentNode.appendChild(connectRoot);
  parentNode.appendChild(script);
}
