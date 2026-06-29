package issue82

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

_issue: {
	number: 82
	title:  "cue(plugin-bundle): define generation and distribution surface"
	path:   "contracts/issues/82/manifest.cue"
	parent: 79
	dependsOn: [80, 81]
}

_workflowIndex: [
	{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
	{order: 2, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
	{order: 3, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
	{order: 4, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
	{order: 5, id: "#MakeValidationPlan", instantiateAt: "_validation"},
	{order: 6, id: "#MakeCompletionReport", instantiateAt: "_completion"},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#PluginBundleGenerationPlan"
			role: "CUE-authored generation plan from template-owned shape and materialized bundle source roots to distributable plugin packages"
			requiredFields: ["templateShape", "sourceRoots", "materializedRoots", "emittedArtifacts", "validation"]
			constraints: [
				"contracts/plugin-bundle/template/template.cue owns the shared source-root shape",
				"contracts/plugin-bundle/*/src roots own bundle-specific source values",
				"generation is deterministic and idempotent",
				"generated plugin packages are projections, not authority",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#PluginBundleDistributionPackage"
			role: "admissible .codex/plugins distribution package emitted from a plugin-bundle source root"
			requiredFields: ["bundleID", "sourceRoot", "distributionRoot", "runtimeFiles", "lockEvidence", "authorityBoundary"]
			constraints: [
				"distribution roots are contained under .codex/plugins/<bundle-id>",
				"runtime files are a declared subset of generated package files",
				"manifest and lock evidence describe the package but do not become source authority",
				"runtime must not require external factory or contract.cuemod lookups",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#PluginBundleGenerationDistributionGate"
			role: "validation gate proving generated distribution artifacts remain projections of admitted CUE source surfaces"
			requiredFields: ["positiveExports", "negativeChecks", "forbiddenAttractors", "distributionDiffPolicy"]
			constraints: [
				"generated artifacts must be reproducible from CUE source inputs",
				"distribution diffs must be reviewable and path-contained",
				"forbidden authority promotion bottoms through explicit checks",
				"generation and distribution do not redefine template shape",
			]
			closed: true
		}
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#PluginBundleGenerationPlan", "#PluginBundleDistributionPackage", "#PluginBundleGenerationDistributionGate"]
		observed: [
			"contracts/plugin-bundle/template/template.cue",
			"contracts/plugin-bundle/agent-context-resolver/src",
			"contracts/plugin-bundle/code-intel/src",
			".codex/plugins/agent-context-resolver",
			".codex/plugins/code-intel",
		]
		candidates: ["#PluginBundleGenerationDistributionCandidate"]
		fixtures: ["negativePluginBundleGenerationDistributionFixtures"]
		checks: ["_negativeBottomChecks"]
		publicExports: [
			"normalizedPluginBundleGenerationDistributionManifest",
			"pluginBundleGenerationDistributionValidationPlan",
			"pluginBundleGenerationDistributionCompletionReportContract",
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name:     "generatedPackageAuthorityAccepted"
			violates: "generated package authority boundary"
			refusal:  "generated .codex plugin packages are distribution projections only"
			input: {
				path:                      ".codex/plugins/agent-context-resolver/manifest.json"
				role:                      "authority"
				generatedPackageAuthority: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "distributionOutsidePluginRootAccepted"
			violates: "distribution root containment"
			refusal:  "plugin-bundle distribution writes must stay under .codex/plugins/<bundle-id>"
			input: {
				bundleID:         "agent-context-resolver"
				distributionRoot: ".codex/../contracts/plugin-bundle/agent-context-resolver/src"
				pathContained:    false
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "nonDeterministicGenerationAccepted"
			violates: "deterministic generation boundary"
			refusal:  "generation outputs must be reproducible from admitted CUE source inputs"
			input: {
				generatedAtRuntime:    true
				nonDeterministicInput: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "runtimeExternalSourceLookupAccepted"
			violates: "runtime distribution independence"
			refusal:  "distributed plugin runtime must not require external factory or contract.cuemod source lookups"
			input: {
				runtimeRequiresExternalFactoryLookup: true
				runtimeRequiresContractCuemodLookup:  true
			}
		}
	},
]

negativePluginBundleGenerationDistributionFixtures: {
	generatedPackageAuthorityAccepted:     _negativeFixtures[0].out
	distributionOutsidePluginRootAccepted: _negativeFixtures[1].out
	nonDeterministicGenerationAccepted:    _negativeFixtures[2].out
	runtimeExternalSourceLookupAccepted:   _negativeFixtures[3].out
}

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "generatedPackageAuthorityAccepted"
			fixture:      negativePluginBundleGenerationDistributionFixtures.generatedPackageAuthorityAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/issues/82/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "distributionOutsidePluginRootAccepted"
			fixture:      negativePluginBundleGenerationDistributionFixtures.distributionOutsidePluginRootAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/issues/82/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "nonDeterministicGenerationAccepted"
			fixture:      negativePluginBundleGenerationDistributionFixtures.nonDeterministicGenerationAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/issues/82/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "runtimeExternalSourceLookupAccepted"
			fixture:      negativePluginBundleGenerationDistributionFixtures.runtimeExternalSourceLookupAccepted.id
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/issues/82/checks"
		}
	},
]

_validation: impl.#MakeValidationPlan & {
	in: {
		path:              "contracts/issues/82"
		validBaselineExpr: "normalizedPluginBundleGenerationDistributionManifest"
		publicExpr:        "normalizedPluginBundleGenerationDistributionManifest"
		bottomChecks: [for plan in _bottomCheckPlans {plan.out.name}]
		checkFile:        "./contracts/issues/82/checks"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: "[g]eneratedPackageAuthority: true|[p]athContained: false|[n]onDeterministicInput: true|[r]untimeRequiresExternalFactoryLookup: true|[r]untimeRequiresContractCuemodLookup: true"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [for fixture in _negativeFixtures {fixture.out.id}]
		checks:   _validation.in.bottomChecks
		commands: _validation.out.commands
		evidence: [
			"template-owned src-root shape from #80",
			"materialized resolver/code-intel src-root conformance from #81",
			"distribution artifacts under .codex/plugins are projections only",
		]
	}
}

normalizedPluginBundleGenerationDistributionManifest: {
	issue:    _issue
	workflow: _workflowIndex
	primitives: [for primitive in _primitives {primitive.out}]
	surfaces:         _surfaces.out
	negativeFixtures: negativePluginBundleGenerationDistributionFixtures
	bottomCheckPlans: [for plan in _bottomCheckPlans {plan.out}]
	generation: {
		templateAuthority: "contracts/plugin-bundle/template/template.cue"
		sourceRoots: [
			"contracts/plugin-bundle/agent-context-resolver/src",
			"contracts/plugin-bundle/code-intel/src",
		]
		distributionRoots: [
			".codex/plugins/agent-context-resolver",
			".codex/plugins/code-intel",
		]
		invariants: [
			"CUE source roots are authority",
			"generated plugin packages are evidence-only projections",
			"runtime package artifacts are path-contained under .codex/plugins",
			"distribution is deterministic and reviewable",
			"runtime does not depend on external source checkouts",
		]
	}
}

pluginBundleGenerationDistributionValidationPlan:           _validation.out
pluginBundleGenerationDistributionCompletionReportContract: _completion.out
