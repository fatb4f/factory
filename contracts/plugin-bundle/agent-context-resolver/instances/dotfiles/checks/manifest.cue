package dotfilespluginbundlechecks

#NonEmptyString: string & !=""

#ResolverPromptSurface: close({
	schema: "agent.resolver-prompt-surface.v1"
	intent: "dotfiles-agent-context-resolver"
	selectedFragments: [...#NonEmptyString]
	selectedRoutes: [...close({id: #NonEmptyString, kind: #NonEmptyString, objective: #NonEmptyString})]
	execution: close({mode: "prompt-only", routeExecution: false, controllerPacket: false, debugEvidence: "stderr-or-file"})
	hints: [...close({text: #NonEmptyString})]
})

#HookEmissionContract: close({
	defaultMode: "compact"
	debugMode:   "debug"
	stdout: close({mode: "compact", payload: #ResolverPromptSurface})
	stderr: close({mode: "debug", optional: true, payload: "route-controller-packet" | "diagnostics" | "none"})
	fullPacketDefaultStdout:     false
	generatedArtifactsAuthority: false
	debug: close({allowed: true, sinks: [..."stderr" | "file"], fullPacketSchema: "agent.route-controller-packet.v1", authority: false})
})

_surfaceBase: {
	schema: "agent.resolver-prompt-surface.v1"
	intent: "dotfiles-agent-context-resolver"
	selectedFragments: ["agent-context-resolver.authority"]
	selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary."}]
	execution: {mode: "prompt-only", routeExecution: false, controllerPacket: false, debugEvidence: "stderr-or-file"}
	hints: [{text: "Emit only the compact prompt surface on UserPromptSubmit stdout."}]
}

_negativeBottomChecks: {
	controllerLeak: *(_surfaceBase & {controller: {schema: "agent.route-plan.v1"}} & #ResolverPromptSurface) | _
	runtimeLeak: *(_surfaceBase & {runtime: {routeRefs: [{routeID: "resolver.inspect.current"}]}} & #ResolverPromptSurface) | _
	availableFragmentIDsLeak: *(_surfaceBase & {availableFragmentIDs: ["agent-context-resolver.authority"]} & #ResolverPromptSurface) | _
	workerBindingIDLeak: *(_surfaceBase & {selectedRoutes: [{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary.", workerBindingID: "agent-context-resolver.validation-worker"}]} & #ResolverPromptSurface) | _
	rawTranscriptLeak: *(_surfaceBase & {rawTranscript: "UserPromptSubmit full transcript"} & #ResolverPromptSurface) | _
	debugPacketAsDefaultOut: *({defaultMode: "compact", debugMode: "debug", stdout: {mode: "compact", payload: {schema: "agent.route-controller-packet.v1"}}, stderr: {mode: "debug", optional: true, payload: "route-controller-packet"}, fullPacketDefaultStdout: false, generatedArtifactsAuthority: false, debug: {allowed: true, sinks: ["stderr", "file"], fullPacketSchema: "agent.route-controller-packet.v1", authority: false}} & #HookEmissionContract) | _
}
