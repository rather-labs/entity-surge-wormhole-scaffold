import type { routes } from "@wormhole-foundation/sdk-connect";
import { NttRoute, nttAutomaticRoute, nttManualRoute } from "@wormhole-foundation/sdk-route-ntt";

export const nttRoutes = (nc: NttRoute.Config): routes.RouteConstructor[] => {
  return [nttManualRoute(nc), nttAutomaticRoute(nc)];
};
