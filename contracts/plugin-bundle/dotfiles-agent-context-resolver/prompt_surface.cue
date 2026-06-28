package dotfilespluginbundle

#PromptSurfaceIntent: "resolver" | "context-resolution" | "dotfiles-agent-context-resolver"

#PromptSurfaceRoute: close({
	id: #NonEmptyString
	kind: "inspect" | "validate" | "generate" | "diff" | "test" | "summarize" | "risk_scan"
	objective: #NonEmptyString
})

#PromptSurfaceExecution: close({
	mode: "prompt-only" | "compact-summary"
	routeExecution: false
	controllerPacket: false
	debugEvidence: "stderr-or-file"
})

#PromptSurfaceHint: close({text: #NonEmptyString})

#ResolverPromptSurface: close({
	schema: "agent.resolver-prompt-surface.v1"
	intent: #PromptSurfaceIntent
	selectedFragments: [...#NonEmptyString]
	selectedRoutes: [...#PromptSurfaceRoute]
	execution: #PromptSurfaceExecution
	hints: [...#PromptSurfaceHint]
})

dotfilesAgentContextResolverPromptSurface: #ResolverPromptSurface & {
	schema: "agent.resolver-prompt-surface.v1"
	intent: "dotfiles-agent-context-resolver"
	selectedFragments: [
		"agent-context-resolver.authority",
		"agent-skill.projection",
		"repo.lifecycle",
		"resolver.context-packet",
	]
	selectedRoutes: [
		{id: "resolver.inspect.current", kind: "inspect", objective: "Inspect resolver authority and generated boundary."},
		{id: "resolver.plan.compile", kind: "validate", objective: "Validate bounded prompt projection without runtime execution."},
		{id: "agent-skill.projection.validate", kind: "validate", objective: "Validate hook and skill projections as generated artifacts."},
	]
	execution: {
		mode: "prompt-only"
		routeExecution: false
		controllerPacket: false
		debugEvidence: "stderr-or-file"
	}
	hints: [
		{text: "Emit only the compact prompt surface on UserPromptSubmit stdout."},
		{text: "Keep the route-controller packet as debug evidence on stderr or in a file."},
		{text: "Treat generated hook artifacts as non-authoritative projections."},
		{text: "Reject controller, runtime, registry, worker binding, and transcript leakage."},
	]
}

#ProjectionDropField: "controller" | "propagation" | "runtime" | "availableFragmentIDs" | "availableRouteIDs" | "workerProfileID" | "workerBindingID" | "preferredWorkerAdapter" | "generatedFrom" | "rawRegistry" | "rawTranscript"

#ResolverPromptProjection: close({
	sourceSchema: "agent.route-controller-packet.v1"
	targetSchema: "agent.resolver-prompt-surface.v1"
	drop: [...#ProjectionDropField]
	stdout: close({payload: "prompt-surface", compact: true})
	debug: close({explicit: true, fullPacketSinks: [..."stderr" | "file"]})
})

dotfilesAgentContextResolverPromptSurfaceProjection: #ResolverPromptProjection & {
	sourceSchema: "agent.route-controller-packet.v1"
	targetSchema: "agent.resolver-prompt-surface.v1"
	drop: ["controller", "propagation", "runtime", "availableFragmentIDs", "availableRouteIDs", "workerProfileID", "workerBindingID", "preferredWorkerAdapter", "generatedFrom", "rawRegistry", "rawTranscript"]
	stdout: {payload: "prompt-surface", compact: true}
	debug: {explicit: true, fullPacketSinks: ["stderr", "file"]}
}
