package factory

#ReflectionGapReport: close({
	schema:                          "factory.reflection-gap-report.v1"
	inventory:                       "factory.reflection-inventory.v1"
	missingAssertions:               [...string]
	missingRequiredValues:           [...string]
	uncoveredProjectionPaths:        [...string]
	unbackedExecutableChecks:        [...string]
	unbackedFixtures:                [...string]
	unbackedEvidence:                [...string]
	nonReproducibleGeneratedOutputs: [...string]
	runtimeAssertionFailures:        [...string]
	status:                          "closed" | "open"
})

reflectionInventory: {
	schema:    "factory.reflection-inventory.v1"
	reflector: "factory.validation-reflector.v1"
	sourceSurfaces: [
		"contracts/factory/assertions/schema.cue",
		"contracts/factory/control.cue",
		"contracts/factory/introspection.cue",
		"contracts/factory/reflection.cue",
		".codex/hooks.json",
		"contracts/agent-context-resolver/generated/route_inventory.json",
	]
	assertionSurfaces: [
		"contracts/factory/assertions/generated/agent_context_hook.cue:#AgentContextHookPacket",
		"contracts/factory/assertions/generated/agent_context_hook.cue:#CodexHooksProjection",
	]
	requiredValues: [
		"packet.schema",
		"packet.selectedFragments subset packet.availableFragmentIDs",
		"packet.controller.authority",
		"packet.controller.routes subset packet.controller.availableRouteIDs",
		"packet.controller.propagation denies raw context",
		"packet.controller.expectedMerge.routeResultsAreAuthority",
		"packet.controller.runtime.execution.allowed",
		"packet.resolver.command",
		"packet.resolver.skill",
		"codex hook command",
	]
	requiredAdapterChecks: [
		"packet serialized byte length < 50000",
	]
	projections: {
		agentContextHook: {
			path:          "generated/checks/agent-context-hook"
			kind:          "generated-executable-check"
			authority:     false
			generatedFrom: "contracts/factory/reflection.cue"
			assertionSurfaces: [
				"contracts/factory/assertions/generated/agent_context_hook.cue:agentContextHookAssertion",
			]
		}
	}
	fixtures: {
		agentContextHookPrompt: {
			path:          "generated/fixtures/agent-context-hook-prompt.json"
			generatedFrom: "contracts/factory/reflection.cue"
			assertion:     "factory.validation.agent-context-hook"
		}
	}
	evidence: {
		materializationReport: {
			path:          "generated/evidence/materialization-report.json"
			generatedFrom: "contracts/factory/reflection.cue"
		}
		controlLoopInput: {
			path:          "generated/evidence/control-loop/input.json"
			generatedFrom: "contracts/factory/introspection.cue"
		}
		controlLoopTransform: {
			path:          "generated/evidence/control-loop/transform.json"
			generatedFrom: "contracts/factory/introspection.cue"
		}
		controlLoopOutput: {
			path:          "generated/evidence/control-loop/output.json"
			generatedFrom: "contracts/factory/introspection.cue"
		}
		controlLoopSensor: {
			path:          "generated/evidence/control-loop/sensor.json"
			generatedFrom: "contracts/factory/introspection.cue"
		}
		controlLoopErrorSignal: {
			path:          "generated/evidence/control-loop/error-signal.json"
			generatedFrom: "contracts/factory/introspection.cue"
		}
		controlLoopControlAction: {
			path:          "generated/evidence/control-loop/control-action.json"
			generatedFrom: "contracts/factory/introspection.cue"
		}
		controlLoopNextState: {
			path:          "generated/evidence/control-loop/next-state.json"
			generatedFrom: "contracts/factory/introspection.cue"
		}
	}
	runtimeEvidence: {
		agentContextHookPacket: {
			path:      "generated/evidence/agent-context-hook.packet.json"
			assertion: "factory.validation.agent-context-hook"
		}
		assertionResults: {
			path:          "generated/evidence/assertion-results.json"
			generatedFrom: "generated/checks/agent-context-hook"
		}
	}
}

materializationPlan: {
	schema:        "factory.validation-materialization-plan.v1"
	generatedFrom: "contracts/factory/reflection.cue"
	contractExtensionProposals: [{
		id:            "factory.validation.agent-context-hook"
		status:        "admitted"
		assertionPath: "contracts/factory/assertions/generated/agent_context_hook.cue"
		fixtures: [reflectionInventory.fixtures.agentContextHookPrompt.path]
		checks:   [reflectionInventory.projections.agentContextHook.path]
		evidence: [
			reflectionInventory.evidence.materializationReport.path,
		]
		runtimeEvidence: [
			reflectionInventory.runtimeEvidence.agentContextHookPacket.path,
			reflectionInventory.runtimeEvidence.assertionResults.path,
		]
		decisionEvidence: {
			errorSignal:   "generated/evidence/control-loop/error-signal.json"
			controlAction: "generated/evidence/control-loop/control-action.json"
			nextState:     "generated/evidence/control-loop/next-state.json"
		}
	}]
}

agentContextHookPrompt: """
# feat(codex): add agent-context-resolver hook aperture

## Objective

factory repo without resolver-backed Codex hooks
  -> repo-local Codex hook aperture
  -> bounded agent-context-resolver prompt/context packet
  -> implementation issue workflow can run without raw GitHub/repo discovery

## Authority boundary

agent-context-resolver
  -> dependency / aperture / prompt-context provider
  -> not factory authority

Codex hook
  -> runtime adapter
  -> not semantic authority

factory contracts
  -> remain under contracts/factory/**
"""
