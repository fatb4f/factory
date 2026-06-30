package agentcontextresolver

import (
	tmpl "github.com/fatb4f/factory/contracts/plugin-bundle/src:pluginbundlesrc"
	graph "github.com/fatb4f/factory/contracts/agent-context-resolver/src/internal/graph:graph"
	"list"
	impl "github.com/fatb4f/factory/contracts/meta"
)

// source: contracts/agent-context-resolver/src/manifest.cue
promptMatcherNegativeFixtures: {
	providerStandalone: {input: {
		id: "bad-provider-standalone"
		matcher: {
			all: []
			any: [{value: "provider", mode: "word", caseFold: true, rawContains: false}]
			none: []
			phrases: []
			paths: []
			wordTerms: [{term: "provider", boundary: "word", regexBoundary: true, rawContains: false}]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["mcp.evidence-plane"]
		invokes: ["mcp.evidence.inspect"]
		hint:     "generic provider trigger must not match alone"
		priority: 1
	}}
	dotfilesStandalone: {input: {
		id: "bad-dotfiles-standalone"
		matcher: {
			all: []
			any: [{value: "dotfiles", mode: "word", caseFold: true, rawContains: false}]
			none: []
			phrases: []
			paths: []
			wordTerms: [{term: "dotfiles", boundary: "word", regexBoundary: true, rawContains: false}]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["repo.lifecycle"]
		invokes: ["repo.lifecycle.validate"]
		hint:     "generic dotfiles trigger must not match alone"
		priority: 1
	}}
	unclosedRouteGraph: {input: {
		promptRouteID: "bad-unclosed-resolver"
		selectedRouteIDs: ["resolver.plan.compile"]
		routes: routeInventory.routes
	}}
}

runtimeProviderExecutionNegativeFixtures: {
	providerExecutionRequired: {input: {
		mode: "none"
		routeRefs: []
		requirements: {
			agentRuntimeRegistry:  "absent"
			workerAdapterRegistry: "absent"
			mcpRouteExecutor:      "present"
		}
		execution: {
			allowed:                false
			preferredWorkerAdapter: "a2a"
			secondaryWorkerAdapters: []
			requiresA2AAdapter:      false
			requiresMCPAdapter:      true
			requiresRuntimeRegistry: false
			backend:                 "none"
		}
		deny: {
			directSDKSpawn:          true
			rawTranscriptForwarding: true
			rawRegistryDump:         true
			unselectedFragments:     true
			globalMutation:          true
			authorityDelegation:     true
			freeFormMCPToolExposure: true
		}
		expectedResult: {schema: "agent.route-result.v1"}
	}}
}

// source: contracts/agent-context-resolver/src/manifest.cue
_materializedBundleShape: tmpl.#PluginBundleSrcRootShape & {
	srcRoot: "contracts/plugin-bundle/agent-context-resolver/src"
	contracts: {
		root: "contracts/plugin-bundle/agent-context-resolver/src"
		cuePackages: [
			{id: "agentcontextresolver", path: "manifest.cue"},
			{id: "agentcontextresolver", path: "manifest.cue"},
			{id: "agentcontextresolver", path: "manifest.cue"},
			{id: "agentcontextresolver", path: "manifest.cue"},
		]
		requiredPaths: [
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
			"manifest.cue",
		]
	}
	generated: {
		root:         "contracts/plugin-bundle/generated/agent-context-resolver"
		evidenceOnly: true
		artifacts: [
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/.codex-plugin/plugin.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/skills/SKILL.md", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/hooks/hooks.json", required: true, evidenceOnly: true},
			{path: "contracts/plugin-bundle/generated/agent-context-resolver/scripts/README.md", required: true, evidenceOnly: true},
		]
	}
	contractProjection: {
		pluginName: "agent-context-resolver"
	}
	generatedProjection: {
		pluginName: "agent-context-resolver"
	}
	validation: {
		commands: [
			"cue vet ./contracts/plugin-bundle/agent-context-resolver/src",
			"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e normalizedMaterializedBundleShapeManifest",
		]
		negativeChecks: ["resolverShapeDrift"]
		forbiddenAttractors: []
	}
	manifest: {
		bundleID:                          "agent-context-resolver"
		shapeVersion:                      "factory.plugin-bundle.src-root-shape.v1"
		srcRootShapeAuthority:             "contracts/plugin-bundle/src/manifest.cue"
		generatedArtifactsAreEvidenceOnly: true
		bundleLocalShapeOverride:          false
	}
	bundleLocalShapeOverride: false
}

normalizedMaterializedBundleShapeManifest: _materializedBundleShape

materializedBundleShapeValidationPlan: close({
	path:     "contracts/plugin-bundle/agent-context-resolver/src"
	positive: _materializedBundleShape.validation.commands
	negative: [
		"! cue export ./contracts/plugin-bundle/src/checks -e _negativeBottomChecks.staleLocalCheckReferenceAccepted",
	]
})

materializedBundleShapeCompletionReportContract: close({
	bundleID:      _materializedBundleShape.manifest.bundleID
	templateShape: _materializedBundleShape.manifest.srcRootShapeAuthority
	srcRoot:       _materializedBundleShape.srcRoot
	validation:    materializedBundleShapeValidationPlan
	finalResult:   "resolver bundle conforms to the template-defined src-root shape"
})

// source: contracts/agent-context-resolver/src/manifest.cue
_negativeBottomChecks: {
	genericProviderTermAccepted:
		*(pluginBundleRecommendationNegativeFixtures.genericProviderTermAccepted.input & #PluginBundleMatcherAdmissible) | _

	danglingDependencyAccepted:
		*(pluginBundleRecommendationNegativeFixtures.danglingDependencyAccepted.input & #PluginBundleMatcherAdmissible) | _

	cueRuntimeDependencyAccepted:
		*(pluginBundleRecommendationNegativeFixtures.cueRuntimeDependencyAccepted.input & #PluginBundleMatcherAdmissible) | _
}

// source: contracts/agent-context-resolver/src/manifest.cue
resolverModuleBoundary: {
	modulePath:    "github.com/fatb4f/factory/contracts/plugin-bundle/agent-context-resolver/src"
	moduleRoot:    "."
	publicSurface: "manifest.cue"
	deferred: ["contracts/agent-runtime"]
}

resolverSectionPackages: {
	assertions: #Section & {id: "agent-context-resolver.assertions", kind: "assertions", path: "assertions"}
	checks: #Section & {id: "agent-context-resolver.checks", kind: "checks", path: "checks"}
	adapters: #Section & {id: "agent-context-resolver.adapters", kind: "adapters", path: "adapters"}
	workers: #Section & {id: "agent-context-resolver.workers", kind: "workers", path: "workers"}
	hooks: #Section & {id: "agent-context-resolver.hooks", kind: "hooks", path: "hooks"}
	fixtures: #Section & {id: "agent-context-resolver.fixtures", kind: "fixtures", path: "fixtures"}
	projections: #Section & {id: "agent-context-resolver.projections", kind: "projections", path: "projections"}
	generated: #Section & {id: "agent-context-resolver.generated", kind: "generated", path: "generated"}
	seed: #Section & {id: "agent-context-resolver.seeds", kind: "seeds", path: "seed"}
}

#Section: close({
	id:   graph.#ID
	kind: graph.#ContractSectionKind
	path: graph.#RelPath
})

agentContextResolver: graph.#ContractDomain & {
	id: "agent-context-resolver"

	model: {
		id:          "agent-context-resolver"
		kind:        "functional-domain"
		package:     "agentcontextresolver"
		rootPath:    "."
		description: "Contained contract domain for resolver authority, lifecycle, generated route controller packets, projections, hooks, and validation evidence."
	}

	root: {
		id:   "agent-context-resolver.root"
		kind: "contract-root"
		path: "."
		rootPath: ["agent-context-resolver.root"]
	}

	sections: {
		"agent-context-resolver.assertions": {
			kind: "assertions"
			path: "assertions"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.assertions"]
			ownedLeaves: [
				"agent-context-resolver.leaf.domain-contract",
				"agent-context-resolver.leaf.proof-contract",
			]
		}
		"agent-context-resolver.fixtures": {
			kind: "fixtures"
			path: "fixtures"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.fixtures"]
			ownedLeaves: [
				"agent-context-resolver.leaf.resolver-fixtures",
				"agent-context-resolver.leaf.workspace-lifecycle-fixtures",
			]
		}
		"agent-context-resolver.adapters": {
			kind: "adapters"
			path: "adapters"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.adapters"]
			ownedLeaves: [
				"agent-context-resolver.leaf.hook-contract",
				"agent-context-resolver.leaf.prompt-classifier-contract",
			]
		}
		"agent-context-resolver.projections": {
			kind: "projections"
			path: "projections"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.projections"]
			ownedLeaves: [
				"agent-context-resolver.leaf.fragments-contract",
				"agent-context-resolver.leaf.projection-contract",
				"agent-context-resolver.leaf.runtime-projection-contract",
				"agent-context-resolver.leaf.registry-contract",
			]
		}
		"agent-context-resolver.generated": {
			kind: "generated"
			path: "generated"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.generated"]
			ownedLeaves: [
				"agent-context-resolver.leaf.generated-fragments",
			]
		}
		"agent-context-resolver.seeds": {
			kind: "seeds"
			path: "seed"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.seeds"]
			ownedLeaves: [
				"agent-context-resolver.leaf.seed-resolver",
			]
		}
		"agent-context-resolver.workers": {
			kind: "workers"
			path: "workers"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.workers"]
			ownedLeaves: [
				"agent-context-resolver.leaf.resolver-worker-binding",
				"agent-context-resolver.leaf.seed-worker-script",
			]
		}
		"agent-context-resolver.checks": {
			kind: "checks"
			path: "checks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.checks"]
			ownedLeaves: [
				"agent-context-resolver.leaf.gates-contract",
				"agent-context-resolver.leaf.merge-contract",
				"agent-context-resolver.leaf.propagation-contract",
				"agent-context-resolver.leaf.route-plan-contract",
				"agent-context-resolver.leaf.routes-contract",
				"agent-context-resolver.leaf.sequencing-contract",
			]
		}
		"agent-context-resolver.hooks": {
			kind: "hooks"
			path: "hooks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.hooks"]
			ownedLeaves: [
				"agent-context-resolver.leaf.agent-context-hook",
			]
		}
	}

	leaves: {
		"agent-context-resolver.leaf.domain-contract": {
			kind:   "assertion"
			parent: "agent-context-resolver.assertions"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.assertions", "agent-context-resolver.leaf.domain-contract"]
			path:        "manifest.cue"
			description: "Contained domain object model and ownership assertions."
		}
		"agent-context-resolver.leaf.proof-contract": {
			kind:   "assertion"
			parent: "agent-context-resolver.assertions"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.assertions", "agent-context-resolver.leaf.proof-contract"]
			path:        "manifest.cue"
			description: "Resolver proof result and check contract."
		}
		"agent-context-resolver.leaf.resolver-fixtures": {
			kind:   "fixture"
			parent: "agent-context-resolver.fixtures"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.fixtures", "agent-context-resolver.leaf.resolver-fixtures"]
			path:        "fixtures/agent-context-resolver"
			description: "Resolver route, fragment, propagation, hook-context, and runtime-denial fixtures."
		}
		"agent-context-resolver.leaf.workspace-lifecycle-fixtures": {
			kind:   "fixture"
			parent: "agent-context-resolver.fixtures"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.fixtures", "agent-context-resolver.leaf.workspace-lifecycle-fixtures"]
			path:        "fixtures/workspace-lifecycle"
			description: "Resolver workspace lifecycle graph, edge, and packet fixtures."
		}
		"agent-context-resolver.leaf.hook-contract": {
			kind:   "adapter"
			parent: "agent-context-resolver.adapters"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.adapters", "agent-context-resolver.leaf.hook-contract"]
			path:        "manifest.cue"
			description: "Hook packet boundary and adapter evidence contract."
		}
		"agent-context-resolver.leaf.prompt-classifier-contract": {
			kind:   "adapter"
			parent: "agent-context-resolver.adapters"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.adapters", "agent-context-resolver.leaf.prompt-classifier-contract"]
			path:        "manifest.cue"
			description: "Prompt classification adapter contract for route selection evidence."
		}
		"agent-context-resolver.leaf.fragments-contract": {
			kind:   "projection"
			parent: "agent-context-resolver.projections"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.projections", "agent-context-resolver.leaf.fragments-contract"]
			path:        "manifest.cue"
			description: "Fragment registry authority projected into resolver context packets."
		}
		"agent-context-resolver.leaf.projection-contract": {
			kind:   "projection"
			parent: "agent-context-resolver.projections"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.projections", "agent-context-resolver.leaf.projection-contract"]
			path:        "manifest.cue"
			description: "Resolver generated artifact projection contract."
		}
		"agent-context-resolver.leaf.runtime-projection-contract": {
			kind:   "projection"
			parent: "agent-context-resolver.projections"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.projections", "agent-context-resolver.leaf.runtime-projection-contract"]
			path:        "manifest.cue"
			description: "Route reference projection contract for runtime-bound evidence."
		}
		"agent-context-resolver.leaf.registry-contract": {
			kind:   "projection"
			parent: "agent-context-resolver.projections"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.projections", "agent-context-resolver.leaf.registry-contract"]
			path:        "manifest.cue"
			description: "Resolver route registry projection source."
		}
		"agent-context-resolver.leaf.generated-fragments": {
			kind:   "generated"
			parent: "agent-context-resolver.generated"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.generated", "agent-context-resolver.leaf.generated-fragments"]
			path:        "generated"
			description: "Generated resolver route, fragment, lifecycle, and turn-start evidence outputs."
		}
		"agent-context-resolver.leaf.seed-resolver": {
			kind:   "seed"
			parent: "agent-context-resolver.seeds"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.seeds", "agent-context-resolver.leaf.seed-resolver"]
			path:        "seed"
			description: "Standalone seed package for the resolver contract slice."
		}
		"agent-context-resolver.leaf.resolver-worker-binding": {
			kind:   "worker"
			parent: "agent-context-resolver.workers"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.workers", "agent-context-resolver.leaf.resolver-worker-binding"]
			path:        "manifest.cue"
			description: "Resolver output and lifecycle binding contract for generated route controller packets."
		}
		"agent-context-resolver.leaf.seed-worker-script": {
			kind:   "worker"
			parent: "agent-context-resolver.workers"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.workers", "agent-context-resolver.leaf.seed-worker-script"]
			path:        "seed/scripts"
			description: "Seed validation and generation scripts used as worker evidence."
		}
		"agent-context-resolver.leaf.gates-contract": {
			kind:   "check"
			parent: "agent-context-resolver.checks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.checks", "agent-context-resolver.leaf.gates-contract"]
			path:        "gates.cue"
			description: "Route gate validation contract."
		}
		"agent-context-resolver.leaf.merge-contract": {
			kind:   "check"
			parent: "agent-context-resolver.checks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.checks", "agent-context-resolver.leaf.merge-contract"]
			path:        "manifest.cue"
			description: "Route result merge validation, deterministic reducer, bounded packet, and synthesis gate contract."
		}
		"agent-context-resolver.leaf.propagation-contract": {
			kind:   "check"
			parent: "agent-context-resolver.checks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.checks", "agent-context-resolver.leaf.propagation-contract"]
			path:        "manifest.cue"
			description: "Route-local propagation validation contract."
		}
		"agent-context-resolver.leaf.route-plan-contract": {
			kind:   "check"
			parent: "agent-context-resolver.checks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.checks", "agent-context-resolver.leaf.route-plan-contract"]
			path:        "manifest.cue"
			description: "Route plan validation contract."
		}
		"agent-context-resolver.leaf.routes-contract": {
			kind:   "check"
			parent: "agent-context-resolver.checks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.checks", "agent-context-resolver.leaf.routes-contract"]
			path:        "manifest.cue"
			description: "Registered resolver route inventory contract."
		}
		"agent-context-resolver.leaf.sequencing-contract": {
			kind:   "check"
			parent: "agent-context-resolver.checks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.checks", "agent-context-resolver.leaf.sequencing-contract"]
			path:        "manifest.cue"
			description: "Route sequencing validation contract."
		}
		"agent-context-resolver.leaf.agent-context-hook": {
			kind:   "hook"
			parent: "agent-context-resolver.hooks"
			rootPath: ["agent-context-resolver.root", "agent-context-resolver.hooks", "agent-context-resolver.leaf.agent-context-hook"]
			path:        "generated/checks/agent-context-hook"
			description: "Hook regression script that validates projected resolver packet evidence."
		}
	}

	authorityEdges: [
		{from: "agent-context-resolver.root", to: "agent-context-resolver.assertions", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.fixtures", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.adapters", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.projections", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.generated", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.seeds", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.workers", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.checks", kind: "owns"},
		{from: "agent-context-resolver.root", to: "agent-context-resolver.hooks", kind: "owns"},
	]

	relations: []

	_ownedLeavesResolve: [
		for _, section in sections
		for _, leafID in section.ownedLeaves {
			leaves[leafID] & {
				parent: section.id
			}
		},
	]

	assertions: {
		"agent-context-resolver.sections-contained": {
			subject: "agent-context-resolver.root"
			fact:    "Every agent-context-resolver contract section has a declared authority path back to the contract root."
			appliesTo: [
				"agent-context-resolver.assertions",
				"agent-context-resolver.fixtures",
				"agent-context-resolver.adapters",
				"agent-context-resolver.projections",
				"agent-context-resolver.generated",
				"agent-context-resolver.seeds",
				"agent-context-resolver.workers",
				"agent-context-resolver.checks",
				"agent-context-resolver.hooks",
			]
			evidence: ["agent-context-resolver.check.sections-contained"]
			polarity: "invariant"
			strength: "required"
		}
		"agent-context-resolver.leaves-owned": {
			subject: "agent-context-resolver.root"
			fact:    "Every section-owned agent-context-resolver leaf ID resolves to a declared leaf with that section as parent."
			appliesTo: [
				"agent-context-resolver.assertions",
				"agent-context-resolver.fixtures",
				"agent-context-resolver.adapters",
				"agent-context-resolver.projections",
				"agent-context-resolver.generated",
				"agent-context-resolver.seeds",
				"agent-context-resolver.workers",
				"agent-context-resolver.checks",
				"agent-context-resolver.hooks",
			]
			evidence: ["agent-context-resolver.check.leaves-owned"]
			polarity: "invariant"
			strength: "required"
		}
		"agent-context-resolver.leaves-rooted": {
			subject: "agent-context-resolver.root"
			fact:    "Every declared agent-context-resolver leaf has a root path beginning at the agent-context-resolver contract root."
			appliesTo: [
				"agent-context-resolver.leaf.domain-contract",
				"agent-context-resolver.leaf.proof-contract",
				"agent-context-resolver.leaf.resolver-fixtures",
				"agent-context-resolver.leaf.workspace-lifecycle-fixtures",
				"agent-context-resolver.leaf.hook-contract",
				"agent-context-resolver.leaf.prompt-classifier-contract",
				"agent-context-resolver.leaf.fragments-contract",
				"agent-context-resolver.leaf.projection-contract",
				"agent-context-resolver.leaf.runtime-projection-contract",
				"agent-context-resolver.leaf.registry-contract",
				"agent-context-resolver.leaf.generated-fragments",
				"agent-context-resolver.leaf.seed-resolver",
				"agent-context-resolver.leaf.resolver-worker-binding",
				"agent-context-resolver.leaf.seed-worker-script",
				"agent-context-resolver.leaf.gates-contract",
				"agent-context-resolver.leaf.merge-contract",
				"agent-context-resolver.leaf.propagation-contract",
				"agent-context-resolver.leaf.route-plan-contract",
				"agent-context-resolver.leaf.routes-contract",
				"agent-context-resolver.leaf.sequencing-contract",
				"agent-context-resolver.leaf.agent-context-hook",
			]
			evidence: ["agent-context-resolver.check.leaves-rooted"]
			polarity: "invariant"
			strength: "required"
		}
		"agent-context-resolver.fixture-obligations-owned": {
			subject: "agent-context-resolver.root"
			fact:    "Every resolver fixture obligation references an existing assertion and targets a declared leaf or an explicitly planned target."
			appliesTo: [
				"agent-context-resolver.assertions",
				"agent-context-resolver.fixtures",
				"agent-context-resolver.checks",
			]
			evidence: ["agent-context-resolver.check.fixture-obligations-owned"]
			polarity: "invariant"
			strength: "required"
		}
		"agent-context-resolver.test-obligations-owned": {
			subject: "agent-context-resolver.root"
			fact:    "Every resolver test obligation references an existing assertion, existing fixture obligations, and an existing check."
			appliesTo: [
				"agent-context-resolver.assertions",
				"agent-context-resolver.fixtures",
				"agent-context-resolver.checks",
			]
			evidence: ["agent-context-resolver.check.test-obligations-owned"]
			polarity: "invariant"
			strength: "required"
		}
		"agent-context-resolver.assertion-coverage-complete": {
			subject: "agent-context-resolver.root"
			fact:    "Every active resolver assertion has declared fixture and test coverage or is explicitly coverage-exempt."
			appliesTo: [
				"agent-context-resolver.assertions",
				"agent-context-resolver.fixtures",
				"agent-context-resolver.checks",
			]
			evidence: ["agent-context-resolver.check.assertion-coverage-complete"]
			polarity: "invariant"
			strength: "required"
		}
		"agent-context-resolver.migration-acceptance-closed": {
			subject: "agent-context-resolver.root"
			fact:    "The resolver closeout can export a bounded controller packet, predefined A2A route-worker invocation schema, deterministic merge reducer, bounded merge packet, adapter bindings, and route-worker evidence without SDK subagents, MCP execution, GitButler, or git-meta."
			appliesTo: [
				"agent-context-resolver.leaf.proof-contract",
				"agent-context-resolver.leaf.merge-contract",
				"agent-context-resolver.leaf.runtime-projection-contract",
				"agent-context-resolver.leaf.route-plan-contract",
				"agent-context-resolver.leaf.routes-contract",
				"agent-context-resolver.leaf.resolver-worker-binding",
				"agent-context-resolver.leaf.generated-fragments",
			]
			evidence: ["agent-context-resolver.check.migration-acceptance-closed"]
			polarity: "invariant"
			strength: "required"
		}
	}

	fixtureObligations: {
		"agent-context-resolver.fixture.leaves-owned.positive.workspace-lifecycle-graph": {
			assertion:   "agent-context-resolver.leaves-owned"
			polarity:    "positive"
			target:      "agent-context-resolver.leaf.workspace-lifecycle-fixtures"
			path:        "fixtures/workspace-lifecycle/graph.cue"
			expected:    "pass"
			generation:  "manual"
			description: "Positive workspace lifecycle fixture proving owned leaf IDs resolve through declared section ownership."
		}
		"agent-context-resolver.fixture.leaves-owned.negative.invalid-route-authority": {
			assertion:   "agent-context-resolver.leaves-owned"
			polarity:    "negative"
			target:      "agent-context-resolver.leaf.resolver-fixtures"
			path:        "fixtures/agent-context-resolver/invalid-route-authority.cue"
			expected:    "fail"
			generation:  "manual"
			description: "Negative resolver fixture proving invalid authority ownership is rejected."
		}
		"agent-context-resolver.fixture.leaves-rooted.positive.workspace-lifecycle-packets": {
			assertion:   "agent-context-resolver.leaves-rooted"
			polarity:    "positive"
			target:      "agent-context-resolver.leaf.workspace-lifecycle-fixtures"
			path:        "fixtures/workspace-lifecycle/packets.cue"
			expected:    "pass"
			generation:  "manual"
			description: "Positive workspace lifecycle fixture proving resolver packets remain rooted in declared leaves."
		}
		"agent-context-resolver.fixture.leaves-rooted.negative.invalid-route-fragment": {
			assertion:   "agent-context-resolver.leaves-rooted"
			polarity:    "negative"
			target:      "agent-context-resolver.leaf.resolver-fixtures"
			path:        "fixtures/agent-context-resolver/invalid-route-fragment.cue"
			expected:    "fail"
			generation:  "manual"
			description: "Negative resolver fixture proving invalid route fragment ownership fails rooted-leaf validation."
		}
		"agent-context-resolver.fixture.migration-acceptance.positive.route-compiler-proof": {
			assertion:   "agent-context-resolver.migration-acceptance-closed"
			polarity:    "positive"
			target:      "agent-context-resolver.leaf.proof-contract"
			path:        "manifest.cue"
			expected:    "pass"
			generation:  "manual"
			description: "Positive proof fixture for the generated controller packet, runtime-denied route-worker invocation model, deterministic reducer, bounded merge packet, and evidence-only closeout."
		}
	}

	testObligations: {
		"agent-context-resolver.test.sections-contained.cue-vet": {
			assertion: "agent-context-resolver.sections-contained"
			fixtures: []
			check: "agent-context-resolver.check.sections-contained"
			command: ["cue vet ."]
			description: "Validate section containment through the resolver domain CUE package."
		}
		"agent-context-resolver.test.leaves-owned.cue-vet": {
			assertion: "agent-context-resolver.leaves-owned"
			fixtures: [
				"agent-context-resolver.fixture.leaves-owned.positive.workspace-lifecycle-graph",
				"agent-context-resolver.fixture.leaves-owned.negative.invalid-route-authority",
			]
			check: "agent-context-resolver.check.leaves-owned"
			command: ["cue vet ."]
			description: "Validate leaf ownership with positive and negative resolver fixture obligations declared as evidence inputs."
		}
		"agent-context-resolver.test.leaves-rooted.cue-eval": {
			assertion: "agent-context-resolver.leaves-rooted"
			fixtures: [
				"agent-context-resolver.fixture.leaves-rooted.positive.workspace-lifecycle-packets",
				"agent-context-resolver.fixture.leaves-rooted.negative.invalid-route-fragment",
			]
			check: "agent-context-resolver.check.leaves-rooted"
			command: ["cue eval . -e agentContextResolver -c"]
			description: "Validate leaf root paths with positive and negative resolver fixture obligations declared as evidence inputs."
		}
		"agent-context-resolver.test.fixture-obligations-owned.cue-eval": {
			assertion: "agent-context-resolver.fixture-obligations-owned"
			fixtures: []
			check: "agent-context-resolver.check.fixture-obligations-owned"
			command: ["cue eval . -e agentContextResolver -c"]
			description: "Validate fixture obligation assertion and target references through graph constraints."
		}
		"agent-context-resolver.test.test-obligations-owned.cue-eval": {
			assertion: "agent-context-resolver.test-obligations-owned"
			fixtures: [
				"agent-context-resolver.fixture.leaves-owned.positive.workspace-lifecycle-graph",
				"agent-context-resolver.fixture.leaves-owned.negative.invalid-route-authority",
				"agent-context-resolver.fixture.leaves-rooted.positive.workspace-lifecycle-packets",
				"agent-context-resolver.fixture.leaves-rooted.negative.invalid-route-fragment",
			]
			check: "agent-context-resolver.check.test-obligations-owned"
			command: ["cue eval . -e agentContextResolver -c"]
			description: "Validate test obligation assertion, fixture, and check references through graph constraints."
		}
		"agent-context-resolver.test.assertion-coverage-complete.cue-eval": {
			assertion: "agent-context-resolver.assertion-coverage-complete"
			fixtures: [
				"agent-context-resolver.fixture.leaves-owned.positive.workspace-lifecycle-graph",
				"agent-context-resolver.fixture.leaves-owned.negative.invalid-route-authority",
				"agent-context-resolver.fixture.leaves-rooted.positive.workspace-lifecycle-packets",
				"agent-context-resolver.fixture.leaves-rooted.negative.invalid-route-fragment",
			]
			check: "agent-context-resolver.check.assertion-coverage-complete"
			command: ["cue eval . -e agentContextResolver -c"]
			description: "Validate active assertion coverage through graph constraints."
		}
		"agent-context-resolver.test.migration-acceptance-closed.cue-export": {
			assertion: "agent-context-resolver.migration-acceptance-closed"
			fixtures: ["agent-context-resolver.fixture.migration-acceptance.positive.route-compiler-proof"]
			check: "agent-context-resolver.check.migration-acceptance-closed"
			command: [
				"cue export . -e agentContextResolver",
				"cue export . -e routeInventory",
				"cue export . -e routeInventoryValidation",
				"cue export . -e routeCompilerProof",
				"cue export . -e agentContextResolver.checkManifest",
				"cue export . -e agentContextResolver.validationCertificate",
			]
			description: "Validate the final resolver migration acceptance exports, including route compiler proof closeout state."
		}
	}

	coverage: {
		"agent-context-resolver.coverage.sections-contained": {
			assertion: "agent-context-resolver.sections-contained"
			requiredFixtures: []
			requiredTests: ["agent-context-resolver.test.sections-contained.cue-vet"]
		}
		"agent-context-resolver.coverage.leaves-owned": {
			assertion: "agent-context-resolver.leaves-owned"
			requiredFixtures: [
				"agent-context-resolver.fixture.leaves-owned.positive.workspace-lifecycle-graph",
				"agent-context-resolver.fixture.leaves-owned.negative.invalid-route-authority",
			]
			requiredTests: ["agent-context-resolver.test.leaves-owned.cue-vet"]
		}
		"agent-context-resolver.coverage.leaves-rooted": {
			assertion: "agent-context-resolver.leaves-rooted"
			requiredFixtures: [
				"agent-context-resolver.fixture.leaves-rooted.positive.workspace-lifecycle-packets",
				"agent-context-resolver.fixture.leaves-rooted.negative.invalid-route-fragment",
			]
			requiredTests: ["agent-context-resolver.test.leaves-rooted.cue-eval"]
		}
		"agent-context-resolver.coverage.fixture-obligations-owned": {
			assertion: "agent-context-resolver.fixture-obligations-owned"
			requiredFixtures: []
			requiredTests: ["agent-context-resolver.test.fixture-obligations-owned.cue-eval"]
		}
		"agent-context-resolver.coverage.test-obligations-owned": {
			assertion: "agent-context-resolver.test-obligations-owned"
			requiredFixtures: [
				"agent-context-resolver.fixture.leaves-owned.positive.workspace-lifecycle-graph",
				"agent-context-resolver.fixture.leaves-owned.negative.invalid-route-authority",
				"agent-context-resolver.fixture.leaves-rooted.positive.workspace-lifecycle-packets",
				"agent-context-resolver.fixture.leaves-rooted.negative.invalid-route-fragment",
			]
			requiredTests: ["agent-context-resolver.test.test-obligations-owned.cue-eval"]
		}
		"agent-context-resolver.coverage.assertion-coverage-complete": {
			assertion: "agent-context-resolver.assertion-coverage-complete"
			requiredFixtures: [
				"agent-context-resolver.fixture.leaves-owned.positive.workspace-lifecycle-graph",
				"agent-context-resolver.fixture.leaves-owned.negative.invalid-route-authority",
				"agent-context-resolver.fixture.leaves-rooted.positive.workspace-lifecycle-packets",
				"agent-context-resolver.fixture.leaves-rooted.negative.invalid-route-fragment",
			]
			requiredTests: ["agent-context-resolver.test.assertion-coverage-complete.cue-eval"]
		}
		"agent-context-resolver.coverage.migration-acceptance-closed": {
			assertion: "agent-context-resolver.migration-acceptance-closed"
			requiredFixtures: ["agent-context-resolver.fixture.migration-acceptance.positive.route-compiler-proof"]
			requiredTests: ["agent-context-resolver.test.migration-acceptance-closed.cue-export"]
		}
	}

	checks: {
		"agent-context-resolver.check.sections-contained": {
			kind: "cue-vet"
			assertions: ["agent-context-resolver.sections-contained"]
			target: "agent-context-resolver.root"
			command: ["cue vet ."]
			failure: "agent-context-resolver contains an orphaned, mis-owned, or unproven contract section."
		}
		"agent-context-resolver.check.leaves-owned": {
			kind: "cue-vet"
			assertions: ["agent-context-resolver.leaves-owned"]
			target: "agent-context-resolver.root"
			command: ["cue vet ."]
			failure: "agent-context-resolver contains a section-owned leaf ID that does not resolve to a declared leaf with the section as parent."
		}
		"agent-context-resolver.check.leaves-rooted": {
			kind: "cue-def"
			assertions: ["agent-context-resolver.leaves-rooted"]
			target: "agent-context-resolver.root"
			command: ["cue eval . -e agentContextResolver -c"]
			expr:    "agentContextResolver"
			failure: "agent-context-resolver contains a declared leaf without a root path beginning at agent-context-resolver.root."
		}
		"agent-context-resolver.check.fixture-obligations-owned": {
			kind: "cue-def"
			assertions: ["agent-context-resolver.fixture-obligations-owned"]
			target: "agent-context-resolver.root"
			command: ["cue eval . -e agentContextResolver -c"]
			expr:    "agentContextResolver"
			failure: "agent-context-resolver contains a fixture obligation with an orphaned assertion or target."
		}
		"agent-context-resolver.check.test-obligations-owned": {
			kind: "cue-def"
			assertions: ["agent-context-resolver.test-obligations-owned"]
			target: "agent-context-resolver.root"
			command: ["cue eval . -e agentContextResolver -c"]
			expr:    "agentContextResolver"
			failure: "agent-context-resolver contains a test obligation with an orphaned assertion, fixture obligation, or check."
		}
		"agent-context-resolver.check.assertion-coverage-complete": {
			kind: "cue-def"
			assertions: ["agent-context-resolver.assertion-coverage-complete"]
			target: "agent-context-resolver.root"
			command: ["cue eval . -e agentContextResolver -c"]
			expr:    "agentContextResolver"
			failure: "agent-context-resolver contains an active assertion without declared coverage."
		}
		"agent-context-resolver.check.migration-acceptance-closed": {
			kind: "cue-export"
			assertions: ["agent-context-resolver.migration-acceptance-closed"]
			target: "agent-context-resolver.root"
			command: [
				"cue export . -e agentContextResolver",
				"cue export . -e routeInventory",
				"cue export . -e routeInventoryValidation",
				"cue export . -e routeCompilerProof",
				"cue export . -e agentContextResolver.checkManifest",
				"cue export . -e agentContextResolver.validationCertificate",
			]
			expr:    "routeCompilerProof"
			failure: "agent-context-resolver migration acceptance is not closed by exported controller packet, route-worker invocation, deterministic reducer, bounded merge packet, adapter binding, and evidence records."
		}
	}

	checkManifest: graph.#CheckManifest & {
		id:     "agent-context-resolver.check-manifest"
		domain: "agent-context-resolver"
		entries: {
			for obligationID, obligation in testObligations {
				"\(obligationID)": {
					testObligation: obligationID
					check:          obligation.check
					assertion:      obligation.assertion
					fixtures:       obligation.fixtures
					command:        obligation.command
					evidenceRequired: {
						assertions: [obligation.assertion]
						fixtures: obligation.fixtures
						check:    obligation.check
					}
				}
			}
		}
	}

	validationCertificate: graph.#ValidationCertificate & {
		id:       "agent-context-resolver.validation-certificate"
		domain:   "agent-context-resolver"
		manifest: checkManifest.id
		entries: {
			for entryID, entry in checkManifest.entries {
				"\(entryID)": {
					manifestEntry:  entry.id
					testObligation: entry.testObligation
					check:          entry.check
					assertion:      entry.assertion
					requiredEvidence: {
						assertions: entry.evidenceRequired.assertions
						fixtures:   entry.evidenceRequired.fixtures
						check:      entry.evidenceRequired.check
						command:    entry.command
					}
				}
			}
		}
	}

	_checkManifestTestObligationRefs: {
		for _, entry in checkManifest.entries {
			"\(entry.id)": testObligations[entry.testObligation]
		}
	}

	_checkManifestCheckRefs: {
		for _, entry in checkManifest.entries {
			"\(entry.id)": checks[entry.check]
		}
	}

	_validationCertificateManifestRefs: {
		for _, entry in validationCertificate.entries {
			"\(entry.id)": checkManifest.entries[entry.manifestEntry]
		}
	}

	workers: {
		"agent-context-resolver.validation-worker": {
			kind:      "validation-worker"
			objective: "Validate agent-context-resolver contract-domain assertions."
			profile: {
				id:               "agent-context-resolver.a2a-worker"
				runtime:          "a2a"
				preferredRuntime: "a2a"
				secondaryAdapters: ["sdk-direct", "mcp", "cli"]
				a2a: {
					runtime:                          "a2a"
					preferred:                        true
					offloadsContext:                  true
					offloadsRouteLocalResponsibility: true
					offloadsAuthority:                false
					inputAuthority:                   "root_codex"
					resultAuthority:                  "evidence_only"
					description:                      "Preferred adapter for bounded route-worker invocation packets."
				}
				controlInvariants: [
					"Adapters execute declared work.",
					"Adapters do not define graph truth.",
					"Workers return evidence, not final authority.",
					"Evidence records report observed results.",
					"Checks declare expected evidence.",
				]
			}
			runtimeAdapter: "a2a"
			allowedNodes: [
				"agent-context-resolver.root",
				"agent-context-resolver.assertions",
				"agent-context-resolver.fixtures",
				"agent-context-resolver.adapters",
				"agent-context-resolver.projections",
				"agent-context-resolver.generated",
				"agent-context-resolver.seeds",
				"agent-context-resolver.workers",
				"agent-context-resolver.checks",
				"agent-context-resolver.hooks",
			]
			deniedNodes: []
			requiredAssertions: [
				"agent-context-resolver.sections-contained",
				"agent-context-resolver.leaves-owned",
				"agent-context-resolver.leaves-rooted",
				"agent-context-resolver.fixture-obligations-owned",
				"agent-context-resolver.test-obligations-owned",
				"agent-context-resolver.assertion-coverage-complete",
				"agent-context-resolver.migration-acceptance-closed",
			]
			pathScope: {
				allowedPaths: [
					"manifest.cue",
					".",
					"generated",
					"fixtures/agent-context-resolver",
					"fixtures/workspace-lifecycle",
					"seed",
					"generated/checks/agent-context-hook",
				]
				deniedPaths: [
					"contracts/repo",
					"contracts/agent-runtime",
					"contracts/agent-skill",
					"contracts/providers",
					"contracts/adapters",
				]
			}
			actions: ["inspect", "run_validation", "collect_evidence"]
			mayMutate:       false
			resultAuthority: "evidence_only"
			protocolSurface: {
				responseItemMetadata: {
					turn_id: "optional"
				}
				sourceIdentityRequired: true
				supportedEnvelopeKinds: ["NEW_TASK", "MESSAGE", "FINAL_ANSWER"]
				payloadBoundary: {
					plaintextEnvelope:               true
					encryptedContent:                true
					plaintextCarriesCorrelationOnly: true
					encryptedContentOpaque:          true
					definesGraphTruth:               false
					mutationAuthority:               false
				}
				authority:         "correlation_only"
				definesGraphTruth: false
				mutationAuthority: false
			}
		}
	}

	adapters: {
		"agent-context-resolver.a2a-adapter": graph.#AdapterContract & #AdapterContract & {
			schema:               "agent.adapter-contract.v1"
			runtime:              "a2a"
			worker:               "agent-context-resolver.validation-worker"
			workerBindingID:      "agent-context-resolver.validation-worker"
			workerProfileID:      "agent-context-resolver.a2a-worker"
			executesDeclaredWork: true
			declaredActions: ["inspect", "run_validation", "collect_evidence"]
			routeIDs: [
				"resolver.inspect.current",
				"resolver.plan.compile",
				"vcs.patch-stack.inspect",
				"mcp.evidence.inspect",
				"agent-skill.projection.validate",
				"resolver.context-packet.inspect",
				"repo.lifecycle.validate",
			]
			declaredRouteIDs: routeIDs
			supportedEnvelopeKinds: ["NEW_TASK", "MESSAGE", "FINAL_ANSWER"]
			payloadBoundary: {
				plaintextEnvelope:               true
				encryptedContent:                true
				plaintextCarriesCorrelationOnly: true
				encryptedContentOpaque:          true
				definesGraphTruth:               false
				mutationAuthority:               false
			}
			inputAuthority:    "root_codex"
			resultAuthority:   "evidence_only"
			definesGraphTruth: false
			deny: {
				semanticAuthority:      true
				graphTruthDefinition:   true
				freeFormToolSelection:  true
				unboundedRouteMutation: true
			}
			description: "A2A route-worker adapter contract for executing declared resolver route work and returning evidence-only results."
		}
	}

	evidenceRecords: {
		"agent-context-resolver.evidence.route-worker-output": graph.#EvidenceRecord & #EvidenceRecord & {
			schema:             "agent.evidence-record.v1"
			kind:               "route-worker-evidence"
			routeID:            "resolver.inspect.current"
			workerID:           "agent-context-resolver.validation-worker"
			profileID:          "agent-context-resolver.a2a-worker"
			adapterID:          "agent-context-resolver.a2a-adapter"
			invocationID:       "agent-context-resolver.invocation.resolver-inspect-current"
			adapterExecutionID: "agent-context-resolver.adapter-execution.resolver-inspect-current"
			routeResultID:      "agent-context-resolver.route-result.resolver-inspect-current"
			adapter:            "a2a"
			responseItemMetadata: {
				turn_id: "agent-context-resolver.turn.resolver-inspect-current"
			}
			sourceIdentity: {
				sourceKind:     "response_item"
				sourceID:       "agent-context-resolver.response-item.resolver-inspect-current"
				producerID:     "agent-context-resolver.validation-worker"
				responseItemID: "resp-item-resolver-inspect-current"
			}
			routeEnvelope: {
				schema:    "codex.multi-agent.route-envelope.v2"
				kind:      "FINAL_ANSWER"
				routeID:   "resolver.inspect.current"
				workerID:  "agent-context-resolver.validation-worker"
				adapterID: "agent-context-resolver.a2a-adapter"
				metadata: {
					turn_id: "agent-context-resolver.turn.resolver-inspect-current"
				}
				sourceIdentity: {
					sourceKind:     "response_item"
					sourceID:       "agent-context-resolver.response-item.resolver-inspect-current"
					producerID:     "agent-context-resolver.validation-worker"
					responseItemID: "resp-item-resolver-inspect-current"
				}
				taskName:  "/agent-context-resolver/validation"
				recipient: "/root-codex"
				sender:    "/agent-context-resolver/validation-worker"
				payload: {
					id:   routeResultID
					kind: "final_answer"
				}
				payloadBoundary: {
					plaintextEnvelope:               true
					encryptedContent:                true
					plaintextCarriesCorrelationOnly: true
					encryptedContentOpaque:          true
					definesGraphTruth:               false
					mutationAuthority:               false
				}
				authority:         "correlation_only"
				definesGraphTruth: false
				mutationAuthority: false
			}
			payloadBoundary: {
				plaintextEnvelope:               true
				encryptedContent:                true
				plaintextCarriesCorrelationOnly: true
				encryptedContentOpaque:          true
				definesGraphTruth:               false
				mutationAuthority:               false
			}
			status:  "partial"
			summary: "Template evidence record for a bounded route-worker output observed through the declared A2A adapter."
			observedEvidence: [
				{kind: "contract", ref: "manifest.cue"},
				{kind: "contract", ref: "manifest.cue"},
			]
			reportsObservedResults: true
			checksExpectedEvidence: true
			authority:              "evidence_only"
			definesGraphTruth:      false
			mutationAuthority:      false
			description:            "Evidence records bind route-worker invocation, adapter execution, and route result observations without becoming semantic authority."
		}
	}

	hooks: {}
}

// source: contracts/agent-context-resolver/src/manifest.cue
#TurnStartFragment: #ProjectedFragment & {
	surface: "turn_start"
}

#TurnStartFragmentSet: {
	generatedFrom: "registry.index.json"
	fragments: [...#TurnStartFragment]
}

turnStartFragmentSet: #TurnStartFragmentSet & {
	generatedFrom: "registry.index.json"
	fragments: [
		for fragment in fragmentInventory.fragments
		if fragment.surface == "turn_start" {
			fragment
		},
	]
}

// source: contracts/agent-context-resolver/src/manifest.cue
#GateClass:
	"registry_authority" |
	"propagation_boundary" |
	"runtime_denial" |
	"structured_result"

#Gate: close({
	id:    #DeclaredID
	class: #GateClass
	stage: "selection" | "projection" | "execution" | "merge"
	appliesToKinds: [...#RouteKind] & [_, ...]
	required: true
})

gateInventory: [...#Gate] & [
	{
		id:    "registry-authority"
		class: "registry_authority"
		stage: "selection"
		appliesToKinds: ["inspect", "validate", "generate", "diff", "test", "summarize", "risk_scan"]
		required: true
	},
	{
		id:    "route-local-propagation"
		class: "propagation_boundary"
		stage: "projection"
		appliesToKinds: ["inspect", "validate", "generate", "diff", "test", "summarize", "risk_scan"]
		required: true
	},
	{
		id:    "runtime-deny"
		class: "runtime_denial"
		stage: "execution"
		appliesToKinds: ["validate", "generate", "diff", "test", "risk_scan"]
		required: true
	},
	{
		id:    "structured-result"
		class: "structured_result"
		stage: "merge"
		appliesToKinds: ["inspect", "validate", "generate", "diff", "test", "summarize", "risk_scan"]
		required: true
	},
]

// source: contracts/agent-context-resolver/src/manifest.cue
#ObservedHookEvent: close({
	source: "claude" | "codex" | "git" | "githubActions" | "manual"
	event:  "preToolUse" | "postToolUse" | "preCommit" | "pullRequest" | "manual"

	cwd: string & !=""

	changedFiles?: [...{
		path:      string & !=""
		operation: "create" | "update" | "delete" | "rename" | "unknown"
	}]

	tool?: {
		name:      string & !=""
		input?:    _
		response?: _
	}
})

// source: contracts/agent-context-resolver/src/manifest.cue
#TurnStartInput: {
	registryIndex: "registry.index.json"
}

#TurnStartOutput: #TurnStartFragmentSet

#UserPromptSubmitInput: {
	prompt: string
	availableFragmentIDs: [...string]
}

#Evidence: {
	kind:   "prompt_term" | "prompt_route" | "route_default"
	value:  string
	source: "user_prompt"
}

#ExpectedEvidence: {
	kind:        "prompt_evidence" | "route_worker_evidence"
	required:    true
	description: string & !=""
}

#UserPromptSubmitOutput: {
	schema: "agent.route-controller-packet.v1"
	selectedFragments: [...string]
	compactHints: [...string]
	evidence: [...#Evidence]
	expectedEvidence?: [...#ExpectedEvidence]
	controller: #ResolvedRoutePlan

	fullRegistry?:   _|_
	contextBodies?:  _|_
	fullTranscript?: _|_
}

#UserPromptSubmitContract: {
	input:  #UserPromptSubmitInput
	output: #UserPromptSubmitOutput

	for _, id in output.selectedFragments {
		list.Contains(input.availableFragmentIDs, id)
	}
}

// source: contracts/agent-context-resolver/src/manifest.cue
_matcherBoundaryChecks: {
	providerStandalone:
		*(#PromptMatcherGuard & {route: promptMatcherNegativeFixtures.providerStandalone.input}) | _

	dotfilesStandalone:
		*(#PromptMatcherGuard & {route: promptMatcherNegativeFixtures.dotfilesStandalone.input}) | _
}

_routeGraphBoundaryChecks: {
	unclosedDependencyGraph: *({
		input: #PromptRouteGraphExpansion & promptMatcherNegativeFixtures.unclosedRouteGraph.input
		_selectedRegisteredRoutes: [
			for route in input.routes
			if list.Contains(input.selectedRouteIDs, route.id) {route},
		]

		for route in _selectedRegisteredRoutes {
			for dependencyID in route.dependsOn {
				if !list.Contains(input.selectedRouteIDs, dependencyID) {
					_missingDependencyClosure: _|_
				}
			}
		}
	}) | _
}

_runtimeBoundaryChecks: {
	mcpAdapterRequired:
		*(#RuntimeProviderExecutionFreeProjection & runtimeProviderExecutionNegativeFixtures.providerExecutionRequired.input) | _
}

// source: contracts/agent-context-resolver/src/manifest.cue
#EvidenceRef: close({
	kind: "file" | "command" | "artifact" | "contract"
	ref:  string & !=""
})

#PatchOp: close({
	op:   "add" | "update" | "delete"
	path: string & !=""
})

#RouteResult: close({
	routeID:    #DeclaredID
	workerID?:  #DeclaredID
	profileID?: #DeclaredID
	adapter?:   #WorkerRuntimeAdapter
	status:     "pass" | "fail" | "blocked" | "partial"
	summary:    string & !=""
	facts?: [...string & !=""]
	evidence?: [...#EvidenceRef]
	responseItemMetadata?: #ResponseItemMetadata
	sourceIdentity?:       #ResponseItemSourceIdentity
	routeEnvelope?:        #MultiAgentV2RouteEnvelope
	touchedPaths?: [...string & !=""]
	diagnostics?: [...string & !=""]
	patchPlan?: [...#PatchOp]
	tokenCost?: int & >=0
	authority:  "evidence_only"
})

#EvidenceRecord: close({
	schema: "agent.evidence-record.v1"
	id:     #DeclaredID
	kind:   "route-worker-evidence"

	routeID:               #DeclaredID
	workerID:              #DeclaredID
	profileID:             #DeclaredID
	adapterID:             #DeclaredID
	invocationID:          #DeclaredID
	adapterExecutionID:    #DeclaredID
	routeResultID:         #DeclaredID
	adapter:               #WorkerRuntimeAdapter
	responseItemMetadata?: #ResponseItemMetadata
	sourceIdentity:        #ResponseItemSourceIdentity
	routeEnvelope: #MultiAgentV2RouteEnvelope & {
		routeID:        routeID
		workerID:       workerID
		adapterID:      adapterID
		metadata?:      responseItemMetadata
		sourceIdentity: sourceIdentity
	}
	payloadBoundary: #PayloadBoundary

	status:  "pass" | "fail" | "blocked" | "partial"
	summary: string & !=""
	observedEvidence: [...#EvidenceRef]
	diagnostics?: [...string & !=""]

	reportsObservedResults: true
	checksExpectedEvidence: bool | *true
	authority:              "evidence_only"
	definesGraphTruth:      false
	mutationAuthority:      false
	description?:           string & !=""
})

#RouteResultEvidenceMapping: close({
	schema: "agent.route-result-evidence-mapping.v1"

	invocation:       #RouteWorkerInvocation
	adapterContract:  #AdapterContract
	adapterExecution: #AdapterExecution
	routeResult:      #RouteResult
	evidenceRecord:   #EvidenceRecord

	adapterContract: {
		id:              evidenceRecord.adapterID
		workerBindingID: invocation.workerID
		workerProfileID: invocation.profileID
	}
	adapterExecution: {
		adapterID:    adapterContract.id
		invocationID: evidenceRecord.invocationID
		routeID:      invocation.routeID
		workerID:     invocation.workerID
	}
	routeResult: {
		routeID:               invocation.routeID
		workerID:              invocation.workerID
		profileID:             invocation.profileID
		adapter:               invocation.adapter
		status:                evidenceRecord.status
		summary:               evidenceRecord.summary
		responseItemMetadata?: evidenceRecord.responseItemMetadata
		sourceIdentity:        evidenceRecord.sourceIdentity
		routeEnvelope:         evidenceRecord.routeEnvelope
		authority:             "evidence_only"
	}
	evidenceRecord: {
		routeID:            invocation.routeID
		workerID:           invocation.workerID
		profileID:          invocation.profileID
		adapterID:          adapterContract.id
		invocationID:       adapterExecution.invocationID
		adapterExecutionID: adapterExecution.id
		adapter:            invocation.adapter
		status:             routeResult.status
		summary:            routeResult.summary
		sourceIdentity:     routeResult.sourceIdentity
		routeEnvelope:      routeResult.routeEnvelope
		authority:          "evidence_only"
		definesGraphTruth:  false
		mutationAuthority:  false
	}
})

#RouteResultSchema: close({
	schema: "agent.route-result.v1"
	result: #RouteResult
})

#MergePolicy: close({
	mode:                     "ordered" | "evidence_weighted" | "fail_closed"
	requireStructuredResults: bool | *true
	requireEvidenceForClaims: bool | *true
	conflictPolicy:           "block" | "prefer_higher_priority" | "root_decides"
	maxMergedSummaryTokens?:  int & >0
	finalAuthority:           "root_codex"
	routeResultsAreAuthority: false
})

#EvidenceCompression: close({
	schema: "agent.evidence-compression.v1"
	stage:  "evidence_compression"
	mode:   "none" | *"bounded"

	input:  "validated_route_results"
	output: "compressed_evidence"

	mayReduceEvidenceVolume: bool | *true
	mustPreserveProvenance:  true
	provenanceFields: [...string & !=""] | *["routeID", "evidence"]

	deny: close({
		eraseProvenance:    true
		rawTranscriptInput: true
	})

	if mode == "none" {
		mayReduceEvidenceVolume: false
	}
})

#BoundedMergePacket: close({
	schema:   "agent.bounded-merge-packet.v1"
	producer: "merge_reducer"
	stage:    "bounded_merge_packet"

	deterministic:            true
	finalAuthority:           "root_codex"
	routeResultsAuthority:    "evidence_only"
	routeResultsAreAuthority: false

	maxSummaryTokens: int & >0
	sourceRouteIDs: [...#DeclaredID]
	facts?: [...string & !=""]
	evidence: [...#EvidenceRef]
	diagnostics?: [...string & !=""]
	conflicts?: [...close({
		routeIDs: [...#DeclaredID] & [_, ...]
		summary:    string & !=""
		resolution: "blocked" | "root_decides"
	})]

	deny: close({
		rawWorkerTranscripts: true
		arbitraryTranscripts: true
		unboundedEvidence:    true
	})
})

#MergeReducer: close({
	schema: "agent.merge-reducer.v1"
	stage:  "merge_reduction"

	input:  "route_results"
	output: "bounded_merge_packet"

	deterministic: true
	steps: [
		"schema_validation",
		"evidence_compression",
		"merge_policy",
		"bounded_merge_packet",
	]
	order: close({
		primary:    "route.sequence"
		tieBreaker: "route.id"
		direction:  "ascending"
	})

	compression: #EvidenceCompression
	policy: #MergePolicy & {
		requireStructuredResults: true
		requireEvidenceForClaims: true
		finalAuthority:           "root_codex"
		routeResultsAreAuthority: false
	}
	packet: #BoundedMergePacket

	deny: close({
		rawWorkerTranscripts: true
		unstructuredResults:  true
		routeResultsAsFinal:  true
	})
})

#ModelSynthesisGate: close({
	schema: "agent.model-synthesis-gate.v1"
	stage:  "model_synthesis"

	allowed: bool | *false
	input: #BoundedMergePacket & {
		producer:      "merge_reducer"
		deterministic: true
	}
	reads: "bounded_merge_packet_only"

	deny: close({
		rawWorkerTranscripts:       true
		arbitraryRouteResultAccess: true
		routeResultsAsAuthority:    true
	})
})

// source: contracts/agent-context-resolver/src/manifest.cue
domainMetadata: {
	id:          "agent-context-resolver"
	kind:        "component"
	authority:   true
	extractable: true
	imports: ["agent-runtime", "context/packet", "adapters"]
}

// source: contracts/agent-context-resolver/src/manifest.cue
_pluginBundleRecommendationWorkflow: [
	{order: 1, id: "#MakePrimitive", constructor: impl.#MakePrimitive, instantiateAt: "_pluginBundlePrimitives"},
	{order: 2, id: "#MakeObservedSurface", constructor: impl.#MakeObservedSurface, instantiateAt: "_pluginBundleObserved"},
	{order: 3, id: "#MakeAdmissibleSurface", constructor: impl.#MakeAdmissibleSurface, instantiateAt: "_pluginBundleAdmissible"},
	{order: 4, id: "#MakePredicateSet", constructor: impl.#MakePredicateSet, instantiateAt: "_pluginBundlePredicates"},
	{order: 5, id: "#MakePromotionCandidate", constructor: impl.#MakePromotionCandidate, instantiateAt: "_pluginBundlePromotion"},
	{order: 6, id: "#MakeSurfaceSet", constructor: impl.#MakeSurfaceSet, instantiateAt: "_pluginBundleSurfaces"},
	{order: 7, id: "#MakeNegativeFixture", constructor: impl.#MakeNegativeFixture, instantiateAt: "_pluginBundleNegativeFixtures"},
	{order: 8, id: "#MakeBottomCheckPlan", constructor: impl.#MakeBottomCheckPlan, instantiateAt: "_pluginBundleBottomCheckPlans"},
	{order: 9, id: "#MakeValidationPlan", constructor: impl.#MakeValidationPlan, instantiateAt: "_pluginBundleValidation"},
	{order: 10, id: "#MakeCompletionReport", constructor: impl.#MakeCompletionReport, instantiateAt: "_pluginBundleCompletion"},
]

_pluginBundleWorkflowIndex: [for step in _pluginBundleRecommendationWorkflow {
	order:         step.order
	id:            step.id
	instantiateAt: step.instantiateAt
}]

_pluginBundleRecommendationSlice: {
	title:             "agent-context-resolver: implement CUE-authored route matching and dependency closure"
	path:              "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"
	sourceTemplateRef: "contracts/meta/scripts/scaffold-contract-slice"
}

_pluginBundleRecommendationIssue: _pluginBundleRecommendationSlice.title

_pluginBundleTargetPaths: [
	"contracts/plugin-bundle/agent-context-resolver/src/manifest.cue",
	"contracts/plugin-bundle/agent-context-resolver/src/manifest.cue",
	"contracts/plugin-bundle/agent-context-resolver/src/**",
	"contracts/plugin-bundle/agent-context-resolver/src/generated/*.json",
	"contracts/plugin-bundle/agent-context-resolver/src/projections/codex/hooks.json",
]

_pluginBundlePrimitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#PluginBundleRouteCatalogue"
			role: "CUE-authored source of truth for exported prompt route, fragment, provider, route, and gate inventories"
			requiredFields: ["promptRoutes", "routes", "fragments", "providers", "gates", "exports"]
			constraints: [
				"CUE owns route catalogue semantics before bundle generation",
				"runtime consumes bundled JSON only",
				"generated JSON is projection evidence and not independent authority",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#PromptMatcherSemantics"
			role: "deterministic trigger language for route selection"
			requiredFields: ["all", "any", "none", "phrases", "wordTerms", "paths"]
			constraints: [
				"generic terms cannot select a route alone",
				"word terms require token boundaries or explicit path semantics",
				"negative terms must suppress otherwise matching routes",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#RouteDependencyClosure"
			role: "closed route graph projection for selected prompt routes"
			requiredFields: ["selectedRoutes", "dependsOn", "expandedRoutes", "sortOrder"]
			constraints: [
				"every emitted dependsOn target must be emitted in the same controller packet",
				"dependency expansion must be recursive",
				"route output remains sorted by sequence, priority, and id after expansion",
			]
			closed: true
		}
	},
]

_pluginBundleObserved: [
	impl.#MakeObservedSurface & {
		in: {
			name: "ObservedPluginBundleRuntime"
			role: "current sh and jq hook plus bundled generated JSON inventory files"
			factFields: ["prompt", "terms", "invokes", "dependsOn", "generatedJson", "runtimeRequirements"]
			constraints: _pluginBundleTargetPaths
		}
	},
]

_pluginBundleAdmissible: [
	impl.#MakeAdmissibleSurface & {
		in: {
			name:            "AdmissiblePluginBundleMatcher"
			role:            "CUE-exported route catalogue consumed by a small jq runtime matcher"
			observedSurface: "ObservedPluginBundleRuntime"
			requiredFields: ["all", "any", "none", "phrases", "wordTerms", "paths", "dependencyClosure"]
			rejectedFields: ["substringOnlyMatch", "cueAtRuntime", "providerExecution", "externalFactoryLookup", "generatedAuthority"]
			constraints: [
				"the hook must keep runtime dependencies to sh and jq",
				"cue export runs during bundle generation or validation only",
				"route matching must be path-aware and boundary-aware",
				"selected route graphs must be dependency-closed before emission",
			]
		}
	},
]

_pluginBundlePredicates: [
	impl.#MakePredicateSet & {
		in: {
			name:              "#PluginBundleMatcherPredicates"
			role:              "admissibility rules for prompt matching and route graph projection"
			observedSurface:   "ObservedPluginBundleRuntime"
			admissibleSurface: "AdmissiblePluginBundleMatcher"
			derivedPredicates: [
				"catalogue-source-is-cue-and-exported-json-is-projection",
				"runtime-dependencies-are-sh-and-jq-only",
				"generic-terms-cannot-trigger-alone",
				"word-terms-are-boundary-aware",
				"path-terms-are-path-aware",
				"negative-terms-suppress-matches",
				"emitted-routes-are-dependency-closed",
				"provider-declarations-are-not-executed-at-runtime",
			]
			constraints: [
				"predicate truth must derive from exported catalogue structure and hook output",
				"runtime observations are evidence only",
			]
		}
	},
]

_pluginBundlePromotion: [
	impl.#MakePromotionCandidate & {
		in: {
			name:              "#PluginBundleMatcherImplementationCandidate"
			role:              "implementation slice for replacing raw contains matching with exported matcher semantics"
			observedSurface:   "ObservedPluginBundleRuntime"
			admissibleSurface: "AdmissiblePluginBundleMatcher"
			predicateSet:      "#PluginBundleMatcherPredicates"
			controlPredicates: [
				"generic-terms-cannot-trigger-alone",
				"emitted-routes-are-dependency-closed",
				"runtime-dependencies-are-sh-and-jq-only",
			]
			admissibilityEvidence: [
				"cue vet ./contracts/plugin-bundle/agent-context-resolver/src",
				"cue export ./contracts/plugin-bundle/agent-context-resolver/src -e pluginBundleRecommendationManifest",
				"hook smoke tests for positive and negative prompts",
			]
			constraints: [
				"do not run CUE inside the prompt hook",
				"do not execute provider tools from the hook",
				"do not depend on external repository checkouts at runtime",
			]
		}
	},
]

_pluginBundleSurfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["AdmissiblePluginBundleMatcher"]
		observed: ["ObservedPluginBundleRuntime"]
		candidates: ["#PluginBundleMatcherImplementationCandidate"]
		fixtures: [
			"negative.genericProviderTermAccepted",
			"negative.danglingDependencyAccepted",
			"negative.cueRuntimeDependencyAccepted",
		]
		checks: [
			"_negativeBottomChecks.genericProviderTermAccepted",
			"_negativeBottomChecks.danglingDependencyAccepted",
			"_negativeBottomChecks.cueRuntimeDependencyAccepted",
		]
		publicExports: [
			"pluginBundleRecommendationManifest",
			"pluginBundleRecommendationValidationPlan",
			"pluginBundleRecommendationCompletionReportContract",
		]
	}
}

_pluginBundleNegativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name:     "genericProviderTermAccepted"
			violates: "generic-terms-cannot-trigger-alone"
			refusal:  "require a phrase, path-aware match, word-boundary match, or required term group before selecting provider-catalogue routes"
			input: {
				prompt: "Update profile provider config"
				terms: ["provider"]
				substringOnlyMatch: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "danglingDependencyAccepted"
			violates: "emitted-routes-are-dependency-closed"
			refusal:  "expand selected routes recursively to include every dependsOn target before emitting a controller packet"
			input: {
				selectedRoutes: ["dotfiles.provider-catalogue.inspect", "dotfiles.plugin-bundle.plan"]
				missingRoutes: ["dotfiles.issue.inspect"]
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "cueRuntimeDependencyAccepted"
			violates: "runtime-dependencies-are-sh-and-jq-only"
			refusal:  "run cue export during generation or validation, then commit bundled JSON for hook runtime"
			input: {
				runtimeRequires: ["sh", "jq", "cue"]
				cueAtRuntime: true
			}
		}
	},
]

pluginBundleRecommendationNegativeFixtures: {
	genericProviderTermAccepted:  _pluginBundleNegativeFixtures[0].out
	danglingDependencyAccepted:   _pluginBundleNegativeFixtures[1].out
	cueRuntimeDependencyAccepted: _pluginBundleNegativeFixtures[2].out
}

_pluginBundleBottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "genericProviderTermAccepted"
			fixture:      "negative.genericProviderTermAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/plugin-bundle/agent-context-resolver/src"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "danglingDependencyAccepted"
			fixture:      "negative.danglingDependencyAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/plugin-bundle/agent-context-resolver/src"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "cueRuntimeDependencyAccepted"
			fixture:      "negative.cueRuntimeDependencyAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/plugin-bundle/agent-context-resolver/src"
		}
	},
]

_pluginBundleValidation: impl.#MakeValidationPlan & {
	in: {
		path:              "contracts/plugin-bundle/agent-context-resolver/src"
		validBaselineExpr: "pluginBundleRecommendationManifest"
		publicExpr:        "pluginBundleRecommendationValidationPlan"
		bottomChecks: [
			"genericProviderTermAccepted",
			"danglingDependencyAccepted",
			"cueRuntimeDependencyAccepted",
		]
		checkFile:        "./contracts/plugin-bundle/agent-context-resolver/src"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: "[s]ubstringOnlyMatchAccepted: true|[c]ueAtRuntimeAccepted: true|[g]eneratedAuthorityAccepted: true"
	}
}

_pluginBundleCompletion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for item in _pluginBundlePrimitives {item.out.name}]
		surfaces: [
			_pluginBundleObserved[0].out.name,
			_pluginBundleAdmissible[0].out.name,
			_pluginBundlePromotion[0].out.name,
		]
		fixtures: [for item in _pluginBundleNegativeFixtures {item.out.id}]
		checks: [for item in _pluginBundleBottomCheckPlans {item.out.name}]
		commands: _pluginBundleValidation.out.commands
		evidence: [
			"constructor library under contracts/meta",
			"plugin-bundle source package under contracts/plugin-bundle/agent-context-resolver/src",
			"review findings for substring matching and dangling route dependencies",
		]
	}
}

pluginBundleRecommendationManifest: {
	issue:    _pluginBundleRecommendationIssue
	workflow: _pluginBundleWorkflowIndex
	primitives: [for item in _pluginBundlePrimitives {item.out}]
	observed: [for item in _pluginBundleObserved {item.out}]
	admissible: [for item in _pluginBundleAdmissible {item.out}]
	predicates: [for item in _pluginBundlePredicates {item.out}]
	promotion: [for item in _pluginBundlePromotion {item.out}]
	surfaces: _pluginBundleSurfaces.out
	negativeFixtures: [for item in _pluginBundleNegativeFixtures {item.out}]
	bottomCheckPlans: [for item in _pluginBundleBottomCheckPlans {item.out}]
}

pluginBundleRecommendationValidationPlan: _pluginBundleValidation.out

pluginBundleRecommendationCompletionReportContract: _pluginBundleCompletion.out

#PluginBundleMatcherAdmissible: close({
	prompt?: string & !=""
	terms?: [...string & !=""]
	substringOnlyMatch?: false

	selectedRoutes?: [...#DeclaredID]
	missingRoutes?: []

	runtimeRequires?: [...(string & !="cue")]
	cueAtRuntime?: false
})

// source: contracts/agent-context-resolver/src/manifest.cue
#ProjectedFragment: {
	id:             string
	sourceContract: string
	sourcePath:     string
	role:           "authority" | "orientation" | "workflow" | "constraint" | "evidence"
	surface:        "turn_start" | "prompt" | "subagent"
	summary:        string
	authorityRoot:  string
	contractPath:   string
}

#FragmentInventory: {
	repo: #RepoContractRegistry.repo
	fragments: [...#ProjectedFragment]
}

fragmentInventory: #FragmentInventory & {
	repo: repoRegistry.repo
	fragments: [
		for contract in repoRegistry.contracts
		for fragment in contract.fragments {
			id:             fragment.id
			sourceContract: fragment.sourceContract
			sourcePath:     fragment.sourcePath
			role:           fragment.role
			surface:        fragment.surface
			summary:        fragment.summary
			authorityRoot:  contract.authorityRoot
			contractPath:   contract.contractPath
		},
	]
}

// source: contracts/agent-context-resolver/src/manifest.cue
#MatcherMode:
	"word" |
	"phrase" |
	"pathGlob" |
	"regexWordBoundary"

#MatcherTerm: close({
	value:       string & !=""
	mode:        #MatcherMode
	caseFold:    true
	rawContains: false
})

#RequiredMatcherGroup: close({
	id: #DeclaredID
	terms: [#MatcherTerm, ...#MatcherTerm]
	semantics: *"all" | "all" | "any"
})

#ExactPhraseTrigger: #MatcherTerm & {
	mode: "phrase"
}

#PathTrigger: close({
	glob:        string & !=""
	repoLocal:   true
	rawContains: false
})

#WordBoundaryTerm: close({
	term:          string & !=""
	boundary:      "word"
	regexBoundary: true
	rawContains:   false
})

#PromptMatcher: close({
	all: *([]) | [...#RequiredMatcherGroup]
	any: *([]) | [...#MatcherTerm]
	none: *([]) | [...#MatcherTerm]
	phrases: *([]) | [...#ExactPhraseTrigger]
	paths: *([]) | [...#PathTrigger]
	wordTerms: *([]) | [...#WordBoundaryTerm]
	semantics: close({
		rawSubstringAllowed:      false
		genericTermMayMatchAlone: false
	})
})

#PromptRoute: close({
	id:      #DeclaredID
	matcher: #PromptMatcher
	selects: [...#DeclaredID] & [_, ...]
	invokes: [...#DeclaredID] & [_, ...]
	hint:     string & !=""
	priority: int & >=0
})

_genericStandaloneTerms: ["provider", "providers", "dotfiles"]

#PromptMatcherGuard: close({
	route: #PromptRoute

	if len(route.matcher.all) == 0 && len(route.matcher.phrases) == 0 && len(route.matcher.paths) == 0 {
		for term in route.matcher.any {
			if list.Contains(_genericStandaloneTerms, term.value) {
				_genericAnyTermCanMatchAlone: _|_
			}
		}
		for term in route.matcher.wordTerms {
			if list.Contains(_genericStandaloneTerms, term.term) {
				_genericWordTermCanMatchAlone: _|_
			}
		}
	}
})

promptMatcherValidation: {
	for promptRoute in promptRoutes {
		"\(promptRoute.id)": #PromptMatcherGuard & {
			route: promptRoute
		}
	}
}

promptRoutes: [...#PromptRoute] & [
	{
		id: "resolver"
		matcher: {
			all: [{
				id:        "resolver-core"
				semantics: "any"
				terms: [
					{value: "resolver", mode: "word"},
					{value: "context", mode: "word"},
					{value: "prompt", mode: "word"},
					{value: "hook", mode: "word"},
					{value: "turnstart", mode: "word"},
				]
			}]
			any: [
				{value: "agent-context-resolver", mode: "phrase"},
				{value: "context resolver", mode: "phrase"},
			]
			none: [
				{value: "provider execution", mode: "phrase"},
				{value: "runtime execution", mode: "phrase"},
			]
			phrases: [
				{value: "agent context resolver", mode: "phrase"},
				{value: "resolve agent context", mode: "phrase"},
			]
			paths: [
				{glob: "contracts/plugin-bundle/agent-context-resolver/**", repoLocal: true},
				{glob: ".codex/plugins/agent-context-resolver/**", repoLocal: true},
			]
			wordTerms: [
				{term: "resolver", boundary: "word", regexBoundary: true},
				{term: "hook", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["agent-context-resolver.authority"]
		invokes: ["resolver.inspect.current", "resolver.plan.compile"]
		hint:     "Apply the resolver lifecycle and generated-fragment boundary."
		priority: 100
	},
	{
		id: "patch-stack"
		matcher: {
			all: [{
				id:        "patch-stack-core"
				semantics: "any"
				terms: [
					{value: "patch", mode: "word"},
					{value: "stack", mode: "word"},
					{value: "rebase", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [{value: "patch stack", mode: "phrase"}]
			paths: [{glob: "contracts/vcs/**", repoLocal: true}]
			wordTerms: [
				{term: "patch", boundary: "word", regexBoundary: true},
				{term: "rebase", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["vcs.patch-stack"]
		invokes: ["vcs.patch-stack.inspect"]
		hint:     "Apply the declared patch-stack workflow."
		priority: 80
	},
	{
		id: "mcp"
		matcher: {
			all: [{
				id:        "mcp-core"
				semantics: "any"
				terms: [
					{value: "mcp", mode: "word"},
					{value: "tool", mode: "word"},
					{value: "server", mode: "word"},
				]
			}]
			any: []
			none: [{value: "provider execution", mode: "phrase"}]
			phrases: [{value: "mcp evidence", mode: "phrase"}]
			paths: [{glob: "contracts/protocols/mcp/**", repoLocal: true}]
			wordTerms: [{term: "mcp", boundary: "word", regexBoundary: true}]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["mcp.evidence-plane"]
		invokes: ["mcp.evidence.inspect"]
		hint:     "Keep MCP results in the evidence plane."
		priority: 80
	},
	{
		id: "skill"
		matcher: {
			all: [{
				id:        "skill-core"
				semantics: "any"
				terms: [
					{value: "skill", mode: "word"},
					{value: "hook", mode: "word"},
					{value: "codex", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [
				{value: "agent skill", mode: "phrase"},
				{value: "codex hook", mode: "phrase"},
			]
			paths: [
				{glob: "contracts/agent-skill/**", repoLocal: true},
				{glob: ".codex/skills/**", repoLocal: true},
			]
			wordTerms: [
				{term: "skill", boundary: "word", regexBoundary: true},
				{term: "codex", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["agent-skill.projection"]
		invokes: ["agent-skill.projection.validate"]
		hint:     "Apply the generated agent skill and hook projection constraints."
		priority: 70
	},
	{
		id: "context-packet"
		matcher: {
			all: [{
				id:        "context-packet-core"
				semantics: "any"
				terms: [
					{value: "context", mode: "word"},
					{value: "packet", mode: "word"},
					{value: "dependency", mode: "word"},
					{value: "projection", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [
				{value: "context packet", mode: "phrase"},
				{value: "dependency projection", mode: "phrase"},
			]
			paths: [{glob: "contracts/context/packet/**", repoLocal: true}]
			wordTerms: [
				{term: "context", boundary: "word", regexBoundary: true},
				{term: "packet", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["resolver.context-packet"]
		invokes: ["resolver.context-packet.inspect"]
		hint:     "Apply the context packet projection workflow."
		priority: 70
	},
	{
		id: "repo"
		matcher: {
			all: [{
				id:        "repo-core"
				semantics: "any"
				terms: [
					{value: "repository", mode: "word"},
					{value: "generated", mode: "word"},
					{value: "fixture", mode: "word"},
				]
			}]
			any: []
			none: []
			phrases: [
				{value: "repo lifecycle", mode: "phrase"},
				{value: "generated output", mode: "phrase"},
			]
			paths: [
				{glob: "contracts/repo/**", repoLocal: true},
				{glob: "generated/**", repoLocal: true},
				{glob: "fixtures/**", repoLocal: true},
			]
			wordTerms: [
				{term: "repository", boundary: "word", regexBoundary: true},
				{term: "fixture", boundary: "word", regexBoundary: true},
			]
			semantics: {rawSubstringAllowed: false, genericTermMayMatchAlone: false}
		}
		selects: ["repo.lifecycle"]
		invokes: ["repo.lifecycle.validate"]
		hint:     "Preserve repository lifecycle and generated-output boundaries."
		priority: 70
	},
]

// source: contracts/agent-context-resolver/src/manifest.cue
#ProofCheck: {
	id:   string
	pass: true
}

#LifecycleReport: {
	version: "contract-cuemod.agent-context-resolver-proof/v1"
	checks: [...#ProofCheck] & [_, ...]
}

routeCompilerProof: #ResolvedRoutePlan & {
	schema:               "agent.route-plan.v1"
	turnID:               "proof-turn"
	intent:               "resolver"
	availableFragmentIDs: _availableFragmentIDs
	availableRouteIDs:    _registeredRouteIDs
	selectedFragments: ["agent-context-resolver.authority"]
	routes: [
		{
			id:             routeInventory.routes[0].id
			kind:           routeInventory.routes[0].kind
			priority:       routeInventory.routes[0].priority
			sequence:       routeInventory.routes[0].sequence
			parallelGroup:  routeInventory.routes[0].parallelGroup
			dependsOn:      routeInventory.routes[0].dependsOn
			inputFragments: routeInventory.routes[0].inputFragments
			task:           routeInventory.routes[0].task
			outputSchema:   routeInventory.routes[0].outputSchema
			gates:          routeInventory.routes[0].gates
		},
		{
			id:             routeInventory.routes[1].id
			kind:           routeInventory.routes[1].kind
			priority:       routeInventory.routes[1].priority
			sequence:       routeInventory.routes[1].sequence
			dependsOn:      routeInventory.routes[1].dependsOn
			inputFragments: routeInventory.routes[1].inputFragments
			task:           routeInventory.routes[1].task
			outputSchema:   routeInventory.routes[1].outputSchema
			gates:          routeInventory.routes[1].gates
		},
	]
	propagation: {
		mode: "route-local"
		root: {
			includes: {
				intent: "resolver"
				selectedFragments: ["agent-context-resolver.authority"]
				acceptedRouteResults: []
			}
			excludes: ["raw route logs", "unvalidated route claims", "runtime implementation details"]
		}
		perRoute: {
			"resolver.inspect.current": {
				includes: {
					objective: routeInventory.routes[0].task.objective
					acceptedFacts: []
					selectedFragments: routeInventory.routes[0].inputFragments
					files: ["contracts/plugin-bundle/agent-context-resolver/src"]
				}
				excludes: ["full transcript", "unselected fragments", "raw registry", "unbounded tool logs", "irrelevant route outputs"]
				return: {
					schema:           routeInventory.routes[0].outputSchema
					maxSummaryTokens: 800
					evidenceRequired: true
				}
			}
			"resolver.plan.compile": {
				includes: {
					objective: routeInventory.routes[1].task.objective
					acceptedFacts: []
					selectedFragments: routeInventory.routes[1].inputFragments
					files: ["contracts/plugin-bundle/agent-context-resolver/src"]
					priorArtifacts: ["resolver.inspect.current"]
				}
				excludes: ["full transcript", "unselected fragments", "raw registry", "unbounded tool logs", "irrelevant route outputs"]
				return: {
					schema:           routeInventory.routes[1].outputSchema
					maxSummaryTokens: 800
					evidenceRequired: true
				}
			}
		}
		denyFullTranscript:      true
		denyRawRegistryDump:     true
		denyUnselectedFragments: true
		requireStructuredResult: true
	}
	gates: gateInventory
	expectedMerge: {
		mode:                     "fail_closed"
		requireStructuredResults: true
		requireEvidenceForClaims: true
		conflictPolicy:           "root_decides"
		maxMergedSummaryTokens:   1200
		finalAuthority:           "root_codex"
		routeResultsAreAuthority: false
	}
	mergeReducer: {
		schema:        "agent.merge-reducer.v1"
		stage:         "merge_reduction"
		input:         "route_results"
		output:        "bounded_merge_packet"
		deterministic: true
		steps: [
			"schema_validation",
			"evidence_compression",
			"merge_policy",
			"bounded_merge_packet",
		]
		order: {
			primary:    "route.sequence"
			tieBreaker: "route.id"
			direction:  "ascending"
		}
		compression: {
			schema:                  "agent.evidence-compression.v1"
			stage:                   "evidence_compression"
			mode:                    "bounded"
			input:                   "validated_route_results"
			output:                  "compressed_evidence"
			mayReduceEvidenceVolume: true
			mustPreserveProvenance:  true
			provenanceFields: ["routeID", "evidence"]
			deny: {
				eraseProvenance:    true
				rawTranscriptInput: true
			}
		}
		policy: expectedMerge
		packet: {
			schema:                   "agent.bounded-merge-packet.v1"
			producer:                 "merge_reducer"
			stage:                    "bounded_merge_packet"
			deterministic:            true
			finalAuthority:           "root_codex"
			routeResultsAuthority:    "evidence_only"
			routeResultsAreAuthority: false
			maxSummaryTokens:         1200
			sourceRouteIDs: [
				routeInventory.routes[0].id,
				routeInventory.routes[1].id,
			]
			facts: []
			evidence: [
				{kind: "contract", ref: "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"},
				{kind: "contract", ref: "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"},
			]
			diagnostics: []
			conflicts: []
			deny: {
				rawWorkerTranscripts: true
				arbitraryTranscripts: true
				unboundedEvidence:    true
			}
		}
		deny: {
			rawWorkerTranscripts: true
			unstructuredResults:  true
			routeResultsAsFinal:  true
		}
	}
	modelSynthesisGate: {
		schema:  "agent.model-synthesis-gate.v1"
		stage:   "model_synthesis"
		allowed: false
		input:   routeCompilerProof.mergeReducer.packet
		reads:   "bounded_merge_packet_only"
		deny: {
			rawWorkerTranscripts:       true
			arbitraryRouteResultAccess: true
			routeResultsAsAuthority:    true
		}
	}
	runtime: {
		mode: "requires-agent-runtime"
		routeRefs: [
			{
				schema:       "agent.runtime-route-reference.v1"
				routeID:      routeInventory.routes[0].id
				routeKind:    routeInventory.routes[0].kind
				context:      routeCompilerProof.propagation.perRoute["resolver.inspect.current"]
				outputSchema: routeInventory.routes[0].outputSchema
			},
			{
				schema:       "agent.runtime-route-reference.v1"
				routeID:      routeInventory.routes[1].id
				routeKind:    routeInventory.routes[1].kind
				context:      routeCompilerProof.propagation.perRoute["resolver.plan.compile"]
				outputSchema: routeInventory.routes[1].outputSchema
			},
		]
		workerInvocations: [
			{
				schema:    "agent.route-worker-invocation.v1"
				routeID:   routeInventory.routes[0].id
				workerID:  "agent-context-resolver.validation-worker"
				profileID: "agent-context-resolver.a2a-worker"
				adapter:   "a2a"
				a2a: {
					runtime:                          "a2a"
					preferred:                        true
					offloadsContext:                  true
					offloadsRouteLocalResponsibility: true
					offloadsAuthority:                false
					rootAuthority:                    "root_codex"
					resultAuthority:                  "evidence_only"
					structuredResult:                 true
				}
				packet: {
					assignedBy: "root_codex"
					bounded:    true
					context:    routeCompilerProof.propagation.perRoute["resolver.inspect.current"]
				}
				returns: {
					schema:           routeInventory.routes[0].outputSchema
					evidenceRequired: true
					authority:        "evidence_only"
				}
				deny: {
					authorityDelegation:      true
					rawTranscriptForwarding:  true
					freeFormMCPToolExposure:  true
					sdkExecutionFromResolver: true
				}
			},
			{
				schema:    "agent.route-worker-invocation.v1"
				routeID:   routeInventory.routes[1].id
				workerID:  "agent-context-resolver.validation-worker"
				profileID: "agent-context-resolver.a2a-worker"
				adapter:   "a2a"
				a2a: {
					runtime:                          "a2a"
					preferred:                        true
					offloadsContext:                  true
					offloadsRouteLocalResponsibility: true
					offloadsAuthority:                false
					rootAuthority:                    "root_codex"
					resultAuthority:                  "evidence_only"
					structuredResult:                 true
				}
				packet: {
					assignedBy: "root_codex"
					bounded:    true
					context:    routeCompilerProof.propagation.perRoute["resolver.plan.compile"]
				}
				returns: {
					schema:           routeInventory.routes[1].outputSchema
					evidenceRequired: true
					authority:        "evidence_only"
				}
				deny: {
					authorityDelegation:      true
					rawTranscriptForwarding:  true
					freeFormMCPToolExposure:  true
					sdkExecutionFromResolver: true
				}
			},
		]
		requirements: {
			agentRuntimeRegistry:  "absent"
			workerAdapterRegistry: "absent"
			mcpRouteExecutor:      "absent"
		}
		execution: {
			allowed:                false
			preferredWorkerAdapter: "a2a"
			secondaryWorkerAdapters: ["sdk-direct", "mcp", "cli"]
			requiresA2AAdapter:      true
			requiresMCPAdapter:      false
			requiresRuntimeRegistry: false
			backend:                 "a2a"
		}
		deny: {
			directSDKSpawn:          true
			rawTranscriptForwarding: true
			rawRegistryDump:         true
			unselectedFragments:     true
			globalMutation:          true
			authorityDelegation:     true
			freeFormMCPToolExposure: true
		}
		expectedResult: {schema: "agent.route-result.v1"}
	}
}

routeEnvelopeProtocolProof: {
	schema: "agent.route-envelope-protocol-proof.v1"

	evidenceRecords: agentContextResolver.evidenceRecords
	checks: [
		for recordID, record in evidenceRecords {
			id:          recordID
			taskName:    record.routeEnvelope.taskName
			recipient:   record.routeEnvelope.recipient
			sender:      record.routeEnvelope.sender
			payloadID:   record.routeEnvelope.payload.id
			payloadKind: record.routeEnvelope.payload.kind

			metadata:       record.routeEnvelope.metadata
			sourceIdentity: record.routeEnvelope.sourceIdentity
			payloadBoundary: record.routeEnvelope.payloadBoundary & {
				encryptedContent: bool
			}

			authority:         record.routeEnvelope.authority & "correlation_only"
			definesGraphTruth: record.routeEnvelope.definesGraphTruth & false
			mutationAuthority: record.routeEnvelope.mutationAuthority & false

			if record.routeEnvelope.kind == "NEW_TASK" {
				payloadKind: "task"
			}
			if record.routeEnvelope.kind == "MESSAGE" {
				payloadKind: "message"
			}
			if record.routeEnvelope.kind == "FINAL_ANSWER" {
				payloadKind: "final_answer"
			}
		},
	]
}

// source: contracts/agent-context-resolver/src/manifest.cue
#BoundaryIncludes: close({
	objective: string & !=""
	acceptedFacts: [...string]
	selectedFragments: [...#DeclaredID]
	files: [...string]
	priorArtifacts?: [...string]
	validationCommands?: [...string]
})

#BoundaryReturn: close({
	schema:            #RouteOutputSchema
	maxSummaryTokens?: int & >0
	evidenceRequired:  bool
})

#RouteContextBoundary: close({
	includes: #BoundaryIncludes
	excludes: [
		"full transcript",
		"unselected fragments",
		"raw registry",
		"unbounded tool logs",
		"irrelevant route outputs",
	]
	return: #BoundaryReturn
})

#RootContextBoundary: close({
	includes: close({
		intent: #PromptIntent
		selectedFragments: [...#DeclaredID]
		acceptedRouteResults: [...#DeclaredID]
	})
	excludes: [
		"raw route logs",
		"unvalidated route claims",
		"runtime implementation details",
	]
})

#PropagationPlan: close({
	mode: "route-local"
	root: #RootContextBoundary
	perRoute: [#DeclaredID]: #RouteContextBoundary
	denyFullTranscript:      true
	denyRawRegistryDump:     true
	denyUnselectedFragments: true
	requireStructuredResult: true
})

// source: contracts/agent-context-resolver/src/manifest.cue
#RepoContractRegistry: {
	repo: {
		id:   string
		root: string
	}

	contracts: [...#ContractAuthority] & [_, ...]
}

#ContractAuthority: {
	id:            string
	authorityRoot: string
	contractPath:  string

	fragments: [...#FragmentDeclaration] & [_, ...]

	hooks?: {
		turnStart?:        bool
		userPromptSubmit?: bool
	}
}

#FragmentDeclaration: {
	id:             string
	sourceContract: string
	sourcePath:     string
	role:           "authority" | "orientation" | "workflow" | "constraint" | "evidence"
	surface:        "turn_start" | "prompt" | "subagent"
	summary:        string
}

repoRegistry: #RepoContractRegistry & {
	repo: {
		id:   "fatb4f/manifest.cuemod"
		root: "."
	}

	contracts: [
		{
			id:            "agent-context-resolver"
			authorityRoot: "contracts/plugin-bundle/agent-context-resolver/src"
			contractPath:  "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"
			hooks: {
				turnStart:        true
				userPromptSubmit: true
			}
			fragments: [
				{
					id:             "agent-context-resolver.authority"
					sourceContract: "agent-context-resolver"
					sourcePath:     "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"
					role:           "authority"
					surface:        "turn_start"
					summary:        "Authoritative resolver lifecycle and context selection boundary."
				},
				{
					id:             "agent-context-resolver.prompt-routing"
					sourceContract: "agent-context-resolver"
					sourcePath:     "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"
					role:           "workflow"
					surface:        "prompt"
					summary:        "Prompt classifier route hints and declared fragment selection rules."
				},
			]
		},
		{
			id:            "agent-runtime"
			authorityRoot: "contracts/agent-runtime"
			contractPath:  "contracts/agent-runtime/manifest.cue"
			fragments: [{
				id:             "agent-runtime.authority"
				sourceContract: "agent-runtime"
				sourcePath:     "contracts/agent-runtime/manifest.cue"
				role:           "authority"
				surface:        "turn_start"
				summary:        "Registered worker, route invocation, budget, lifecycle, adapter, and structured-result boundary."
			}]
		},
		{
			id:            "agent-skill"
			authorityRoot: "contracts/agent-skill"
			contractPath:  "contracts/agent-skill/manifest.cue"
			fragments: [{
				id:             "agent-skill.projection"
				sourceContract: "agent-skill"
				sourcePath:     "contracts/agent-skill/manifest.cue"
				role:           "constraint"
				surface:        "turn_start"
				summary:        "Generated agent skill, hook, and script projection constraints."
			}]
		},
		{
			id:            "mcp"
			authorityRoot: "contracts/protocols/mcp"
			contractPath:  "contracts/protocols/mcp/mcp.cue"
			fragments: [{
				id:             "mcp.evidence-plane"
				sourceContract: "mcp"
				sourcePath:     "contracts/protocols/mcp/mcp.cue"
				role:           "constraint"
				surface:        "turn_start"
				summary:        "MCP provider, result, and evidence-plane constraints."
			}]
		},
		{
			id:            "resolver"
			authorityRoot: "contracts/context/packet"
			contractPath:  "contracts/context/packet/manifest.cue"
			fragments: [{
				id:             "resolver.context-packet"
				sourceContract: "resolver"
				sourcePath:     "contracts/context/packet/manifest.cue"
				role:           "workflow"
				surface:        "turn_start"
				summary:        "Context packet selection and dependency projection workflow."
			}]
		},
		{
			id:            "repo"
			authorityRoot: "contracts/repo"
			contractPath:  "contracts/repo/lifecycle.cue"
			fragments: [
				{
					id:             "repo.lifecycle"
					sourceContract: "repo"
					sourcePath:     "contracts/repo/lifecycle.cue"
					role:           "constraint"
					surface:        "turn_start"
					summary:        "Repository source, generated, fixture, and lifecycle boundaries."
				},
				{
					id:             "repo.contract-seed"
					sourceContract: "repo"
					sourcePath:     "contracts/repo/contract_seed.cue"
					role:           "authority"
					surface:        "turn_start"
					summary:        "Temporary shared contract atom seed for later vb-contract rebasing."
				},
			]
		},
		{
			id:            "vcs"
			authorityRoot: "contracts/vcs"
			contractPath:  "contracts/vcs/patch_stack_manifest.cue"
			fragments: [{
				id:             "vcs.patch-stack"
				sourceContract: "vcs"
				sourcePath:     "contracts/vcs/patch_stack_manifest.cue"
				role:           "workflow"
				surface:        "turn_start"
				summary:        "Patch stack ownership, ordering, and validation workflow."
			}]
		},
		{
			id:            "vb-contract"
			authorityRoot: "contracts/repo"
			contractPath:  "contracts/repo/manifest.cue"
			fragments: [
				{
					id:             "vb-contract.authority"
					sourceContract: "vb-contract"
					sourcePath:     "contracts/repo/manifest.cue"
					role:           "authority"
					surface:        "turn_start"
					summary:        "Temporary virtual-branch contract root and registry contribution."
				},
				{
					id:             "vb-contract.contract-seed"
					sourceContract: "vb-contract"
					sourcePath:     "contracts/repo/contract_seed.cue"
					role:           "constraint"
					surface:        "turn_start"
					summary:        "Temporary contract, template, instance, and projection bootstrap seed."
				},
				{
					id:             "vb-contract.component-seed"
					sourceContract: "vb-contract"
					sourcePath:     "contracts/repo/component_seed.cue"
					role:           "constraint"
					surface:        "turn_start"
					summary:        "Shared reusable component ownership, dependency, glue, and gate schema."
				},
				{
					id:             "vb-contract.virtual-branch"
					sourceContract: "vb-contract"
					sourcePath:     "contracts/repo/virtual_branch.cue"
					role:           "constraint"
					surface:        "turn_start"
					summary:        "Shared reusable virtual-branch schema with separate temporary bootstrap instances."
				},
			]
		},
	]
}

// source: contracts/agent-context-resolver/src/manifest.cue
#DeclaredID: string & =~"^[a-z0-9][a-z0-9._-]*$"

#ContextFragment: close({
	id:                             #DeclaredID
	surface:                        "turn_start" | "prompt" | "mcp"
	channel:                        "message" | "item" | "resource"
	itemKind:                       "message" | "resource" | "tool_output"
	expectedNativeContextInjection: bool
	label:                          string & !=""

	if surface == "turn_start" {
		channel:                        "message"
		itemKind:                       "message"
		expectedNativeContextInjection: true
	}
	if surface != "turn_start" {
		expectedNativeContextInjection: false
	}
	if itemKind == "tool_output" {
		expectedNativeContextInjection: false
	}
})

#Registry: close({
	fragments: [...#ContextFragment]
})

#TurnStartContextFragmentSet: close({
	fragments: [...#ContextFragment & {surface: "turn_start"}]
})

#PromptHint: close({
	domain?:        string
	workflow?:      string
	authorityRoot?: string
	risk?:          string
})

#PromptEvidence: close({
	matchedRules: [...string & !=""]
	rejectedRules?: [...string & !=""]
})

#PromptClassification: close({
	selectedFragments: [...#DeclaredID]
	hints:    #PromptHint
	evidence: #PromptEvidence
})

#LifecycleAssertionName:
	"turn_start_available" |
	"known_fragment_selected" |
	"context_body_not_assembled" |
	"mcp_tool_output_not_implied_context" |
	"controller_packet_not_sdk_subagent"

#LifecycleAssertion: close({
	name:    #LifecycleAssertionName
	passed:  true
	detail?: string & !=""
})

#ResolverLifecycleReport: close({
	schema:         "agent.context-resolver.lifecycle-report.v1"
	registry:       #Registry
	turnStart:      #TurnStartContextFragmentSet
	classification: #PromptClassification
	assertions: [#LifecycleAssertion, ...#LifecycleAssertion]
	for _, id in classification.selectedFragments {
		list.Contains([for fragment in registry.fragments {fragment.id}], id)
		list.Contains([for fragment in turnStart.fragments {fragment.id}], id)
	}
})

#ResolverOutput: close({
	schema: "agent.context-resolver.output.v1"
	prompt: string & !=""
	report: #ResolverLifecycleReport
	hook: close({
		hook_event_name: "UserPromptSubmit"
		selectedFragments: [...#DeclaredID]
		hints:      #PromptHint
		evidence:   #PromptEvidence
		controller: #ResolvedRoutePlan
	})
})

#RegistryMatch: {
	registry:       #Registry
	classification: #PromptClassification

	allowedFragmentIDs: [for entry in registry.fragments {entry.id}]

	for _, id in classification.selectedFragments {
		list.Contains(allowedFragmentIDs, id)
	}
}

// source: contracts/agent-context-resolver/src/manifest.cue
// #ResolvedRoutePlan is the generated controller packet produced by resolver
// authority. It describes route planning inputs, gates, propagation, and merge
// policy; it is not an SDK subagent or a route executor.
#ResolvedRoutePlan: {
	schema:      "agent.route-plan.v1"
	plannerKind: "generated_controller_packet"
	authority:   "resolver_projection"
	turnID:      string & !=""
	intent:      #PromptIntent
	availableFragmentIDs: [...#DeclaredID]
	availableRouteIDs: [...#DeclaredID]
	selectedFragments: [...#DeclaredID] & [_, ...]
	routes: [...#RouteInvocation] & [_, ...]
	propagation: #PropagationPlan
	gates: [...#Gate] & [_, ...]
	expectedMerge:       #MergePolicy
	runtime?:            #RuntimeProjection
	mergeReducer?:       #MergeReducer
	modelSynthesisGate?: #ModelSynthesisGate

	_routeIDs: [for route in routes {route.id}]

	for fragmentID in selectedFragments {
		if !list.Contains(availableFragmentIDs, fragmentID) {
			_invalidSelectedFragment: _|_
		}
	}
	for route in routes {
		if !list.Contains(availableRouteIDs, route.id) {
			_invalidRoute: _|_
		}
		for fragmentID in route.inputFragments {
			if !list.Contains(selectedFragments, fragmentID) {
				_invalidRouteFragment: _|_
			}
		}
		for dependencyID in route.dependsOn {
			if !list.Contains(_routeIDs, dependencyID) {
				_invalidDependency: _|_
			}
		}
	}
}

// source: contracts/agent-context-resolver/src/manifest.cue
#PromptIntent: #DeclaredID

#RouteKind:
	"inspect" |
	"validate" |
	"generate" |
	"diff" |
	"test" |
	"summarize" |
	"risk_scan"

#RouteTask: close({
	objective: string & !=""
	constraints: [...string & !=""]
	files?: [...string & !=""]
	commands?: [...string & !=""]
})

#RouteOutputSchema: close({
	schema: string & !=""
})

#RouteInvocation: close({
	id:             #DeclaredID
	kind:           #RouteKind
	priority:       int & >=0
	sequence:       int & >=0
	parallelGroup?: #DeclaredID
	dependsOn: [...#DeclaredID]
	inputFragments: [...#DeclaredID] & [_, ...]
	task:         #RouteTask
	outputSchema: #RouteOutputSchema
	gates: [...#DeclaredID] & [_, ...]
	workerProfileID?:        #DeclaredID
	workerBindingID?:        #DeclaredID
	preferredWorkerAdapter?: #WorkerRuntimeAdapter | *"a2a"
})

#RegisteredRoute: close({
	#RouteInvocation
	promptRouteIDs: [...#DeclaredID] & [_, ...]
})

#RouteInventory: close({
	generatedFrom: "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"
	routes: [...#RegisteredRoute] & [_, ...]
	gates: [...#Gate] & [_, ...]
})

#RouteInventoryDependencyValidation: close({
	inventory: #RouteInventory
	registeredRouteIDs: [for route in inventory.routes {route.id}]

	for route in inventory.routes {
		for dependencyID in route.dependsOn {
			if !list.Contains(registeredRouteIDs, dependencyID) {
				_missingDependencyTarget: _|_
			}
		}
	}
})

#RouteOrderingContract: close({
	sortBy: ["sequence", "priority", "id"]
	sequenceOrder:         "ascending"
	priorityOrder:         "descending-within-sequence"
	generatorOwnsOrdering: true
})

#PromptRouteGraphExpansion: close({
	promptRouteID: #DeclaredID
	selectedRouteIDs: [...#DeclaredID] & [_, ...]
	routes: [...#RegisteredRoute] & [_, ...]
	ordering: #RouteOrderingContract | *{
		sortBy: ["sequence", "priority", "id"]
		sequenceOrder:         "ascending"
		priorityOrder:         "descending-within-sequence"
		generatorOwnsOrdering: true
	}
})

routeInventory: #RouteInventory & {
	generatedFrom: "contracts/plugin-bundle/agent-context-resolver/src/manifest.cue"
	gates:         gateInventory
	routes: [
		{
			id:            "resolver.inspect.current"
			kind:          "inspect"
			priority:      100
			sequence:      10
			parallelGroup: "inspect"
			dependsOn: []
			inputFragments: ["agent-context-resolver.authority"]
			task: {
				objective: "Inspect the current resolver authority and generated boundary."
				constraints: ["Treat CUE and repository state as durable authority."]
				files: ["contracts/plugin-bundle/agent-context-resolver/src"]
			}
			outputSchema: {schema: "agent.route-result.inspect.v1"}
			gates: ["registry-authority", "route-local-propagation", "structured-result"]
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
			promptRouteIDs: ["resolver"]
		},
		{
			id:       "resolver.plan.compile"
			kind:     "validate"
			priority: 95
			sequence: 20
			dependsOn: ["resolver.inspect.current"]
			inputFragments: ["agent-context-resolver.authority"]
			task: {
				objective: "Compile and validate a generated route controller packet."
				constraints: [
					"Reference registered routes and selected fragments only.",
					"Keep root Codex as merge and synthesis authority.",
					"Do not execute routes or spawn SDK subagents during route planning.",
				]
			}
			outputSchema: {schema: "agent.route-result.validation.v1"}
			gates: ["registry-authority", "route-local-propagation", "runtime-deny", "structured-result"]
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
			promptRouteIDs: ["resolver"]
		},
		{
			id:            "vcs.patch-stack.inspect"
			kind:          "inspect"
			priority:      80
			sequence:      10
			parallelGroup: "inspect"
			dependsOn: []
			inputFragments: ["vcs.patch-stack"]
			task: {
				objective: "Inspect the declared patch-stack workflow."
				constraints: ["Do not mutate repository state during route inspection."]
			}
			outputSchema: {schema: "agent.route-result.inspect.v1"}
			gates: ["registry-authority", "route-local-propagation", "structured-result"]
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
			promptRouteIDs: ["patch-stack"]
		},
		{
			id:            "mcp.evidence.inspect"
			kind:          "inspect"
			priority:      80
			sequence:      10
			parallelGroup: "inspect"
			dependsOn: []
			inputFragments: ["mcp.evidence-plane"]
			task: {
				objective: "Inspect MCP evidence-plane constraints."
				constraints: ["Do not promote tool output into implied context."]
			}
			outputSchema: {schema: "agent.route-result.inspect.v1"}
			gates: ["registry-authority", "route-local-propagation", "structured-result"]
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
			promptRouteIDs: ["mcp"]
		},
		{
			id:       "agent-skill.projection.validate"
			kind:     "validate"
			priority: 70
			sequence: 20
			dependsOn: []
			inputFragments: ["agent-skill.projection"]
			task: {
				objective: "Validate generated agent skill and hook projections."
				constraints: ["Regenerate derived assets from CUE authority."]
				commands: ["generated/checks/agent-context-hook"]
			}
			outputSchema: {schema: "agent.route-result.validation.v1"}
			gates: ["registry-authority", "route-local-propagation", "structured-result"]
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
			promptRouteIDs: ["skill"]
		},
		{
			id:            "resolver.context-packet.inspect"
			kind:          "inspect"
			priority:      70
			sequence:      10
			parallelGroup: "inspect"
			dependsOn: []
			inputFragments: ["resolver.context-packet"]
			task: {
				objective: "Inspect context packet projection constraints."
				constraints: ["Return structured evidence without forwarding parent context."]
			}
			outputSchema: {schema: "agent.route-result.inspect.v1"}
			gates: ["registry-authority", "route-local-propagation", "structured-result"]
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
			promptRouteIDs: ["context-packet"]
		},
		{
			id:       "repo.lifecycle.validate"
			kind:     "validate"
			priority: 70
			sequence: 20
			dependsOn: []
			inputFragments: ["repo.lifecycle"]
			task: {
				objective: "Validate repository lifecycle and generated-output boundaries."
				constraints: ["Do not treat projection artifacts as source authority."]
			}
			outputSchema: {schema: "agent.route-result.validation.v1"}
			gates: ["registry-authority", "route-local-propagation", "structured-result"]
			workerProfileID:        "agent-context-resolver.a2a-worker"
			workerBindingID:        "agent-context-resolver.validation-worker"
			preferredWorkerAdapter: "a2a"
			promptRouteIDs: ["repo"]
		},
	]
}

routeDependencyValidation: #RouteInventoryDependencyValidation & {
	inventory: routeInventory
}

promptRouteExpansions: [
	for promptRoute in promptRoutes {
		promptRouteID:    promptRoute.id
		selectedRouteIDs: promptRoute.invokes
		routes:           routeInventory.routes
	},
]

promptRouteGraphValidation: {
	for expansion in promptRouteExpansions {
		"\(expansion.promptRouteID)": {
			input: #PromptRouteGraphExpansion & expansion
			_selectedRegisteredRoutes: [
				for route in input.routes
				if list.Contains(input.selectedRouteIDs, route.id) {route},
			]

			for route in _selectedRegisteredRoutes {
				for dependencyID in route.dependsOn {
					if !list.Contains(input.selectedRouteIDs, dependencyID) {
						_missingDependencyClosure: _|_
					}
				}
			}
		}
	}
}

_availableFragmentIDs: [for fragment in turnStartFragmentSet.fragments {fragment.id}]
_registeredRouteIDs: [for route in routeInventory.routes {route.id}]
_registeredGateIDs: [for gate in routeInventory.gates {gate.id}]
_boundWorkerIDs: [for _, worker in agentContextResolver.workers {worker.id}]
_boundWorkerProfileIDs: [for _, worker in agentContextResolver.workers {worker.profile.id}]
_boundAdapterRuntimes: [for _, adapter in agentContextResolver.adapters {adapter.runtime}]

routeInventoryValidation: {
	for route in routeInventory.routes {
		if !list.Contains(_boundWorkerIDs, route.workerBindingID) {
			_unboundWorker: _|_
		}
		if !list.Contains(_boundWorkerProfileIDs, route.workerProfileID) {
			_unboundWorkerProfile: _|_
		}
		if !list.Contains(_boundAdapterRuntimes, route.preferredWorkerAdapter) {
			_unboundWorkerAdapter: _|_
		}
		for fragmentID in route.inputFragments {
			if !list.Contains(_availableFragmentIDs, fragmentID) {
				_invalidFragment: _|_
			}
		}
		for gateID in route.gates {
			if !list.Contains(_registeredGateIDs, gateID) {
				_invalidGate: _|_
			}
		}
		for dependencyID in route.dependsOn {
			if !list.Contains(_registeredRouteIDs, dependencyID) {
				_invalidDependency: _|_
			}
		}
	}
}

// source: contracts/agent-context-resolver/src/manifest.cue
#WorkerRuntimeAdapter:
	"a2a" |
	"sdk-direct" |
	"mcp" |
	"cli"

#ResponseItemMetadata: close({
	turn_id?: string & !=""
})

#ResponseItemSourceIdentity: close({
	sourceKind:      "response_item" | "route_worker" | "adapter_execution"
	sourceID:        #DeclaredID
	producerID?:     #DeclaredID
	responseItemID?: string & !=""
})

#MultiAgentV2EnvelopeKind:
	"NEW_TASK" |
	"MESSAGE" |
	"FINAL_ANSWER"

#AgentPath: string & =~"^/[A-Za-z0-9._/-]+$"

#A2APayloadKind:
	"task" |
	"message" |
	"final_answer" |
	"route_result" |
	"evidence"

#A2APayloadRef: close({
	id:   #DeclaredID
	kind: #A2APayloadKind
})

#PayloadBoundary: close({
	plaintextEnvelope: true
	encryptedContent:  bool

	plaintextCarriesCorrelationOnly: true
	encryptedContentOpaque:          true
	definesGraphTruth:               false
	mutationAuthority:               false
})

#MultiAgentV2RouteEnvelope: close({
	schema: "codex.multi-agent.route-envelope.v2"
	kind:   #MultiAgentV2EnvelopeKind

	routeID:         #DeclaredID
	workerID?:       #DeclaredID
	adapterID?:      #DeclaredID
	metadata?:       #ResponseItemMetadata
	sourceIdentity:  #ResponseItemSourceIdentity
	taskName:        #AgentPath
	recipient:       #AgentPath
	sender:          #AgentPath
	payload:         #A2APayloadRef
	payloadBoundary: #PayloadBoundary

	authority:         "correlation_only"
	definesGraphTruth: false
	mutationAuthority: false

	if kind == "NEW_TASK" {
		payload: {
			kind: "task"
		}
	}

	if kind == "MESSAGE" {
		payload: {
			kind: "message"
		}
	}

	if kind == "FINAL_ANSWER" {
		payload: {
			kind: "final_answer"
		}
	}
})

#A2AWorkerAdapter: close({
	runtime:   "a2a"
	preferred: true

	offloadsContext:                  true
	offloadsRouteLocalResponsibility: true
	offloadsAuthority:                false

	rootAuthority:    "root_codex"
	resultAuthority:  "evidence_only"
	structuredResult: true
})

#WorkerProfile: close({
	id: #DeclaredID

	runtime:          #WorkerRuntimeAdapter | *"a2a"
	preferredRuntime: "a2a" | *"a2a"
	secondaryAdapters: [...#WorkerRuntimeAdapter] | *["sdk-direct", "mcp", "cli"]

	a2a: #A2AWorkerAdapter & {
		runtime:   "a2a"
		preferred: true
	}

	controlInvariants: [...string & !=""] | *[
		"Workers are predefined adapter-backed capabilities.",
		"Root Codex assigns bounded invocation packets.",
		"Workers return structured evidence.",
		"A2A offloads context and route-local responsibility.",
		"A2A does not offload authority.",
	]

	if runtime == "a2a" {
		preferredRuntime: "a2a"
	}
})

#WorkerBinding: close({
	id: #DeclaredID

	profileID:      #DeclaredID
	runtimeAdapter: #WorkerRuntimeAdapter | *"a2a"

	routeIDs: [...#DeclaredID] & [_, ...]

	bounded:                true
	resultAuthority:        "evidence_only"
	structuredResultSchema: #RouteOutputSchema

	deny: close({
		freeFormMCPToolExposure: true
		authorityDelegation:     true
		unboundedInvocation:     true
	})
})

#AdapterContract: close({
	schema: "agent.adapter-contract.v1"
	id:     #DeclaredID

	runtime:         #WorkerRuntimeAdapter
	worker?:         #DeclaredID
	workerBindingID: #DeclaredID
	workerProfileID: #DeclaredID

	executesDeclaredWork: true
	routeIDs?: [...#DeclaredID]
	declaredRouteIDs: [...#DeclaredID] & [_, ...]
	supportedEnvelopeKinds: [...#MultiAgentV2EnvelopeKind] | *["NEW_TASK", "MESSAGE", "FINAL_ANSWER"]
	payloadBoundary: #PayloadBoundary
	declaredActions: [
		"inspect" |
		"run_validation" |
		"collect_evidence",
		...,
	]

	inputAuthority:    "root_codex"
	resultAuthority:   "evidence_only"
	definesGraphTruth: false

	deny: close({
		semanticAuthority:      true
		graphTruthDefinition:   true
		freeFormToolSelection:  true
		unboundedRouteMutation: true
	})

	description?: string & !=""
})

#AdapterExecution: close({
	schema: "agent.adapter-execution.v1"
	id:     #DeclaredID

	adapterID:    #DeclaredID
	invocationID: #DeclaredID
	routeID:      #DeclaredID
	workerID:     #DeclaredID
	envelope: #MultiAgentV2RouteEnvelope & {
		routeID:   routeID
		workerID:  workerID
		adapterID: adapterID
	}

	executesDeclaredWork: true
	resultAuthority:      "evidence_only"
	definesGraphTruth:    false
})

#RuntimeRouteReference: close({
	schema:       "agent.runtime-route-reference.v1"
	routeID:      #DeclaredID
	routeKind:    #RouteKind
	context:      #RouteContextBoundary
	outputSchema: #RouteOutputSchema
})

#RouteWorkerInvocation: close({
	schema: "agent.route-worker-invocation.v1"

	routeID:   #DeclaredID
	workerID:  #DeclaredID
	profileID: #DeclaredID

	adapter: #WorkerRuntimeAdapter | *"a2a"
	a2a:     #A2AWorkerAdapter

	packet: close({
		assignedBy: "root_codex"
		bounded:    true
		context:    #RouteContextBoundary
	})

	returns: close({
		schema:           #RouteOutputSchema
		evidenceRequired: true
		authority:        "evidence_only"
	})

	deny: close({
		authorityDelegation:      true
		rawTranscriptForwarding:  true
		freeFormMCPToolExposure:  true
		sdkExecutionFromResolver: true
	})
})

#RuntimeProjection: close({
	mode: "none" | "eligible" | "requires-agent-runtime"
	routeRefs: [...#RuntimeRouteReference]
	workerInvocations?: [...#RouteWorkerInvocation]
	adapterContracts?: [...#AdapterContract]

	requirements: close({
		agentRuntimeRegistry:  "absent" | "present"
		workerAdapterRegistry: "absent" | "present" | *"absent"
		mcpRouteExecutor:      "absent" | "present"
	})

	execution: close({
		allowed:                bool
		preferredWorkerAdapter: "a2a" | *"a2a"
		secondaryWorkerAdapters: [...#WorkerRuntimeAdapter] | *["sdk-direct", "mcp", "cli"]
		requiresA2AAdapter:      bool | *true
		requiresMCPAdapter:      bool | *false
		requiresRuntimeRegistry: bool | *true
		backend:                 "none" | "codex-sdk" | "a2a"
	})

	deny: close({
		directSDKSpawn:          true
		rawTranscriptForwarding: true
		rawRegistryDump:         true
		unselectedFragments:     true
		globalMutation:          true
		authorityDelegation:     true
		freeFormMCPToolExposure: true
	})

	expectedResult: close({
		schema: "agent.route-result.v1"
	})

	if mode == "requires-agent-runtime" {
		execution: allowed: false
	}
	if execution.allowed {
		mode: "eligible"
		routeRefs: [_, ...]
		requirements: {
			agentRuntimeRegistry:  "present"
			workerAdapterRegistry: "present"
		}
		execution: {
			requiresA2AAdapter:      true
			requiresRuntimeRegistry: true
		}
	}
})

// source: contracts/agent-context-resolver/src/manifest.cue
#RuntimeProviderExecutionBoundary: close({
	schema:                                                "agent.runtime-provider-boundary.v1"
	runtimeInventoryContainsProviderExecutionRequirements: false
	mcpRouteExecutor:                                      "absent"
	requiresMCPAdapter:                                    false
	providerOutputAuthority:                               false
})

#RuntimeProviderExecutionFreeProjection: #RuntimeProjection & {
	requirements: {
		mcpRouteExecutor: "absent"
	}
	execution: {
		requiresMCPAdapter: false
	}
}

runtimeProviderExecutionBoundary: #RuntimeProviderExecutionBoundary & {
	schema:                                                "agent.runtime-provider-boundary.v1"
	runtimeInventoryContainsProviderExecutionRequirements: false
	mcpRouteExecutor:                                      "absent"
	requiresMCPAdapter:                                    false
	providerOutputAuthority:                               false
}

// source: contracts/agent-context-resolver/src/manifest.cue
#SequencedRouteSet: {
	routes: [...#RouteInvocation] & [_, ...]

	_routeIDs: [for route in routes {route.id}]

	for route in routes {
		for dependencyID in route.dependsOn {
			if !list.Contains(_routeIDs, dependencyID) {
				_invalidDependency: _|_
			}
		}
	}
}
