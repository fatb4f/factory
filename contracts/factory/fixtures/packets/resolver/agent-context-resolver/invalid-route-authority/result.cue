package invalidrouteauthority

import "github.com/fatb4f/factory/contracts/plugin-bundle/agent-context-resolver/src:agentcontextresolver"

invalid: agentcontextresolver.#RouteResult & {
	routeID:   "resolver.inspect.current"
	status:    "pass"
	summary:   "Route attempted to become final authority."
	authority: "final"
}
