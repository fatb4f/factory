package dotfilespluginbundle

#HookEmissionMode: "compact" | "debug"

#DebugEmissionBoundary: close({
	allowed: true
	sinks: [..."stderr" | "file"]
	fullPacketSchema: "agent.route-controller-packet.v1"
	authority: false
})

#HookStdoutContract: close({
	mode:    "compact"
	payload: #ResolverPromptSurface
})

#HookStderrContract: close({
	mode:     "debug"
	optional: true
	payload:  "route-controller-packet" | "diagnostics" | "none"
})

#HookEmissionContract: close({
	defaultMode: "compact"
	debugMode:   "debug"
	stdout:      #HookStdoutContract
	stderr:      #HookStderrContract

	fullPacketDefaultStdout: false
	generatedArtifactsAuthority: false
	debug: #DebugEmissionBoundary
})

dotfilesAgentContextResolverHookEmissionContract: #HookEmissionContract & {
	defaultMode: "compact"
	debugMode:   "debug"
	stdout: {
		mode:    "compact"
		payload: dotfilesAgentContextResolverPromptSurface
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
}
