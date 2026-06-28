package dotfilespluginbundle

promptSurfaceControllerPacketFixture: {
	schema: "agent.route-controller-packet.v1"
	availableFragmentIDs: ["agent-context-resolver.authority", "agent-skill.projection"]
	selectedFragments: ["agent-context-resolver.authority"]
	controller: {
		schema: "agent.route-plan.v1"
		availableRouteIDs: ["resolver.inspect.current"]
		routes: [{
			id: "resolver.inspect.current"
			kind: "inspect"
			workerProfileID: "agent-context-resolver.a2a-worker"
			workerBindingID: "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
		}]
		propagation: {mode: "route-local"}
		runtime: {routeRefs: [{routeID: "resolver.inspect.current"}]}
	}
	generatedFrom: {routeInventory: "generated/route_inventory.json"}
}

promptSurfaceFixtureBase: {
	schema: "agent.resolver-prompt-surface.v1"
	intent: "dotfiles-agent-context-resolver"
	selectedFragments: ["agent-context-resolver.authority"]
	selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary."}]
	execution: {mode: "prompt-only", routeExecution: false, controllerPacket: false, debugEvidence: "stderr-or-file"}
	hints: [{text: "Emit only the compact prompt surface on UserPromptSubmit stdout."}]
}

dotfilesAgentContextResolverPromptSurfaceNegativeFixtures: {
	controllerLeak: {input: promptSurfaceFixtureBase & {controller: promptSurfaceControllerPacketFixture.controller}}
	runtimeLeak: {input: promptSurfaceFixtureBase & {runtime: promptSurfaceControllerPacketFixture.controller.runtime}}
	propagationLeak: {input: promptSurfaceFixtureBase & {propagation: promptSurfaceControllerPacketFixture.controller.propagation}}
	availableFragmentIDsLeak: {input: promptSurfaceFixtureBase & {availableFragmentIDs: promptSurfaceControllerPacketFixture.availableFragmentIDs}}
	availableRouteIDsLeak: {input: promptSurfaceFixtureBase & {availableRouteIDs: promptSurfaceControllerPacketFixture.controller.availableRouteIDs}}
	workerProfileIDLeak: {input: promptSurfaceFixtureBase & {selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary.", workerProfileID: "agent-context-resolver.a2a-worker"}]}}
	workerBindingIDLeak: {input: promptSurfaceFixtureBase & {selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary.", workerBindingID: "agent-context-resolver.validation-worker"}]}}
	preferredWorkerAdapterLeak: {input: promptSurfaceFixtureBase & {selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary.", preferredWorkerAdapter: "a2a"}]}}
	generatedFromLeak: {input: promptSurfaceFixtureBase & {generatedFrom: promptSurfaceControllerPacketFixture.generatedFrom}}
	rawRegistryLeak: {input: promptSurfaceFixtureBase & {rawRegistry: {fragments: promptSurfaceControllerPacketFixture.availableFragmentIDs}}}
	rawTranscriptLeak: {input: promptSurfaceFixtureBase & {rawTranscript: "UserPromptSubmit full transcript"}}
	debugPacketAsDefaultOut: {input: {
		defaultMode: "compact"
		debugMode: "debug"
		stdout: {mode: "compact", payload: promptSurfaceControllerPacketFixture}
		stderr: {mode: "debug", optional: true, payload: "route-controller-packet"}
		fullPacketDefaultStdout: false
		generatedArtifactsAuthority: false
		debug: {allowed: true, sinks: ["stderr", "file"], fullPacketSchema: "agent.route-controller-packet.v1", authority: false}
	}}
}
