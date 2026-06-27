package dotfilespromptsurfacechecks

import "list"

#NonEmptyString: string & !=""

#PromptSurfaceRoute: close({
	id:        #NonEmptyString
	kind:      "inspect" | "validate" | "generate" | "diff" | "test" | "summarize" | "risk_scan"
	objective: #NonEmptyString
})

#ResolverPromptSurface: close({
	schema:            "agent.resolver-prompt-surface.v1"
	intent:            "resolver" | "context-resolution" | "dotfiles-agent-context-resolver"
	selectedFragments: [...#NonEmptyString]
	selectedRoutes:    [...#PromptSurfaceRoute]
	execution: close({
		mode:             "prompt-only" | "compact-summary"
		routeExecution:   false
		controllerPacket: false
		debugEvidence:    "stderr-or-file"
	})
	hints: [...close({
		text: #NonEmptyString
	})] & list.MaxItems(5)
})

#HookEmissionContract: close({
	defaultMode: "compact"
	debugMode:   "debug"
	stdout: close({
		mode:    "compact"
		payload: #ResolverPromptSurface
	})
	stderr: close({
		mode:     "debug"
		optional: true
		payload:  "route-controller-packet" | "diagnostics" | "none"
	})
	fullPacketDefaultStdout: false
	generatedArtifactsAuthority: false
	debug: close({
		allowed: true
		sinks: [..."stderr" | "file"]
		fullPacketSchema: "agent.route-controller-packet.v1"
		authority: false
	})
})

_surfaceBase: {
	schema: "agent.resolver-prompt-surface.v1"
	intent: "dotfiles-agent-context-resolver"
	selectedFragments: ["agent-context-resolver.authority"]
	selectedRoutes: [{
		id:        "resolver.inspect.current"
		kind:      "inspect"
		objective: "Inspect resolver authority and generated boundary."
	}]
	execution: {
		mode:             "prompt-only"
		routeExecution:   false
		controllerPacket: false
		debugEvidence:    "stderr-or-file"
	}
	hints: [{text: "Emit only the compact prompt surface on UserPromptSubmit stdout."}]
}

_controllerPacket: {
	schema: "agent.route-controller-packet.v1"
	availableFragmentIDs: ["agent-context-resolver.authority"]
	controller: {
		availableRouteIDs: ["resolver.inspect.current"]
		propagation: {
			mode: "route-local"
		}
		runtime: {
			routeRefs: [{routeID: "resolver.inspect.current"}]
		}
	}
	generatedFrom: {
		routeInventory: "contracts/agent-context-resolver/generated/route_inventory.json"
	}
}

_negativeBottomChecks: {
	controllerLeak:
		*(_surfaceBase & {controller: _controllerPacket.controller} & #ResolverPromptSurface) | _

	runtimeLeak:
		*(_surfaceBase & {runtime: _controllerPacket.controller.runtime} & #ResolverPromptSurface) | _

	propagationLeak:
		*(_surfaceBase & {propagation: _controllerPacket.controller.propagation} & #ResolverPromptSurface) | _

	availableFragmentIDsLeak:
		*(_surfaceBase & {availableFragmentIDs: _controllerPacket.availableFragmentIDs} & #ResolverPromptSurface) | _

	availableRouteIDsLeak:
		*(_surfaceBase & {availableRouteIDs: _controllerPacket.controller.availableRouteIDs} & #ResolverPromptSurface) | _

	workerProfileIDLeak:
		*(_surfaceBase & {
			selectedRoutes: [{
				id:              "resolver.inspect.current"
				kind:            "inspect"
				objective:       "Inspect resolver authority and generated boundary."
				workerProfileID: "agent-context-resolver.a2a-worker"
			}]
		} & #ResolverPromptSurface) | _

	workerBindingIDLeak:
		*(_surfaceBase & {
			selectedRoutes: [{
				id:              "resolver.inspect.current"
				kind:            "inspect"
				objective:       "Inspect resolver authority and generated boundary."
				workerBindingID: "agent-context-resolver.validation-worker"
			}]
		} & #ResolverPromptSurface) | _

	preferredWorkerAdapterLeak:
		*(_surfaceBase & {
			selectedRoutes: [{
				id:                     "resolver.inspect.current"
				kind:                   "inspect"
				objective:              "Inspect resolver authority and generated boundary."
				preferredWorkerAdapter: "a2a"
			}]
		} & #ResolverPromptSurface) | _

	generatedFromLeak:
		*(_surfaceBase & {generatedFrom: _controllerPacket.generatedFrom} & #ResolverPromptSurface) | _

	rawRegistryLeak:
		*(_surfaceBase & {rawRegistry: {fragments: _controllerPacket.availableFragmentIDs}} & #ResolverPromptSurface) | _

	rawTranscriptLeak:
		*(_surfaceBase & {rawTranscript: "UserPromptSubmit full transcript"} & #ResolverPromptSurface) | _

	debugPacketAsDefaultOut:
		*({
			defaultMode: "compact"
			debugMode:   "debug"
			stdout: {
				mode:    "compact"
				payload: _controllerPacket
			}
			stderr: {
				mode:     "debug"
				optional: true
				payload:  "route-controller-packet"
			}
			fullPacketDefaultStdout: false
			generatedArtifactsAuthority: false
			debug: {
				allowed: true
				sinks: ["stderr", "file"]
				fullPacketSchema: "agent.route-controller-packet.v1"
				authority: false
			}
		} & #HookEmissionContract) | _
}
