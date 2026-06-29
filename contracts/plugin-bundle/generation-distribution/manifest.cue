package pluginbundlegenerationdistribution

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

_issue: {
	number:    82
	title:     "cue(plugin-bundle): define generation and distribution surface"
	path:      "contracts/plugin-bundle/generation-distribution/manifest.cue"
	issuePath: "contracts/issues/82/manifest.cue"
	parent:    79
	dependsOn: [80, 81]
}

_crossRepoIssue: {
	number:    83
	title:     "cue(plugin-bundle): define cross-repo generation and distribution targets"
	path:      "contracts/plugin-bundle/generation-distribution/manifest.cue"
	issuePath: "contracts/issues/83/manifest.cue"
	parent:    79
	dependsOn: [80, 81, 82]
}

_materializationIssue: {
	number:    84
	title:     "plugin-bundle: materialize generated runtime packages"
	path:      "contracts/plugin-bundle/generation-distribution/manifest.cue"
	issuePath: "contracts/plugin-bundle/generation-distribution/manifest.cue"
	parent:    83
	dependsOn: [42, 83]
}

_contractSeed: close({
	id:         "plugin-bundle-materialization"
	version:    "v0.1.0"
	owner:      "factory/plugin-bundle"
	idempotent: true
})

_repo: close({
	repository:         "fatb4f/factory"
	module:             "github.com/fatb4f/factory/cuemod"
	constructorLibrary: "contracts/meta/impl"
	issueRoot:          ".github/ISSUE_TEMPLATE/contracts"
	templatePath:       ".github/ISSUE_TEMPLATE/contracts/_template/manifest.cue"
	sourceAuthority:    "contracts/plugin-bundle/generation-distribution"
	planExport:         "pluginBundleMaterializationPlan"
})

_issues: close({
	parent: close({
		title: "plugin-bundle: materialize generated runtime packages"
		path:  "contracts/plugin-bundle/generation-distribution/manifest.cue"
		dependsOn: [42, 83]
	})
	materializerFunction: close({
		title:  "plugin-bundle: implement idempotent materializer function"
		path:   "contracts/plugin-bundle/generation-distribution/manifest.cue"
		parent: 84
		dependsOn: [83]
	})
	agentContextResolverMaterialization: close({
		title:  "plugin-bundle: materialize agent-context-resolver for factory and dotfiles"
		path:   "contracts/plugin-bundle/generation-distribution/manifest.cue"
		parent: 84
		dependsOn: [84, 83]
	})
})

#PluginBundleGenerationPlan: close({
	templateShape: string & !=""
	sourceRoots: [...string & !=""] & [_, ...]
	materializedRoots: [...string & !=""] & [_, ...]
	emittedArtifacts: [...#PluginBundleDistributionPackage]
	validation: #PluginBundleGenerationDistributionGate
})

#PluginBundleDistributionPackage: close({
	bundleID:         string & !=""
	sourceRoot:       string & =~"^contracts/plugin-bundle/[^/]+/src$"
	distributionRoot: string & =~"^\\.codex/plugins/[^/]+$"
	runtimeFiles: [...string & !=""]
	lockEvidence: [...string & !=""]
	authorityBoundary: "projection-only"
})

#PluginBundleGenerationDistributionGate: close({
	positiveExports: [...string & !=""] & [_, ...]
	negativeChecks: [...string & !=""]
	forbiddenAttractors: [...string & !=""]
	distributionDiffPolicy: "path-contained-reviewable"
})

#GeneratedPackageAuthorityBoundary: close({
	path:                       string & =~"^\\.codex/plugins/[^/]+/.+"
	role:                       "projection"
	generatedPackageAuthority?: false
})

#DistributionRootContainmentBoundary: close({
	bundleID:         string & !=""
	distributionRoot: string & =~"^\\.codex/plugins/[^/]+$"
	pathContained:    true
})

#DeterministicGenerationBoundary: close({
	generatedAtRuntime?:    false
	nonDeterministicInput?: false
})

#RuntimeExternalSourceLookupBoundary: close({
	runtimeRequiresExternalFactoryLookup?: false
	runtimeRequiresContractCuemodLookup?:  false
})

#PluginBundleMaterializationProgram: close({
	sourceAuthority: _repo.sourceAuthority
	planExport:      _repo.planExport
	materializer:    #PluginBundleMaterializerFunctionRef
	targets: [...#PluginBundleMaterializationTarget] & [_, ...]
})

#PluginBundleMaterializerFunctionRef: close({
	issue:                  string | int
	role:                   "idempotent projection writer"
	mustBeDeterministic:    true
	mustBeIdempotent:       true
	mustBePathContained:    true
	mustNotOwnPolicy:       true
	mustNotOwnAuthority:    true
	mustEmitReviewableDiff: true
})

#PluginBundleMaterializerFunction: close({
	inputExport:     _repo.planExport
	sourceAuthority: _repo.sourceAuthority
	writeRoot:       ".codex/plugins"
	modes: [...("plan" | "check" | "apply")] & ["plan", "check", "apply"]
	idempotent:        true
	deterministic:     true
	pathContained:     true
	projectionOnly:    true
	authorityBoundary: "projection-only"
	lockEvidence: close({
		recordsSourceAuthority: true
		recordsGeneratedFiles:  true
		isAuthority:            false
	})
})

#PluginBundleMaterializationTarget: close({
	sourceBundle:      string & !=""
	sourceAuthority:   _repo.sourceAuthority
	targetRepository:  string & !=""
	targetPath:        string & =~"^\\.codex/plugins/[^/]+$"
	distributionMode:  "repo-local-runtime-projection" | "consumer-runtime-projection"
	authorityBoundary: "projection-only"
	pathContained:     true
	reviewableDiff:    true
})

#AgentContextResolverMaterializationTarget: #PluginBundleMaterializationTarget & close({
	sourceBundle:     "agent-context-resolver"
	targetRepository: "fatb4f/factory" | "fatb4f/dotfiles"
	targetPath:       ".codex/plugins/agent-context-resolver"
	distributionMode: "repo-local-runtime-projection" | "consumer-runtime-projection"
})

#AgentContextResolverMaterializationSlice: close({
	bundleID:              "agent-context-resolver"
	sourceAuthority:       _repo.sourceAuthority
	dependsOnMaterializer: 84
	targets: [
		#AgentContextResolverMaterializationTarget & {
			targetRepository: "fatb4f/factory"
			distributionMode: "repo-local-runtime-projection"
		},
		#AgentContextResolverMaterializationTarget & {
			targetRepository: "fatb4f/dotfiles"
			distributionMode: "consumer-runtime-projection"
		},
	]
	idempotent:     true
	deterministic:  true
	projectionOnly: true
})

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

_bottomCheckNames: [
	"generatedPackageAuthorityAccepted",
	"distributionOutsidePluginRootAccepted",
	"nonDeterministicGenerationAccepted",
	"runtimeExternalSourceLookupAccepted",
]

_bottomCheckPlans: [
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "generatedPackageAuthorityAccepted"
			fixture:      "generatedPackageAuthorityAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/plugin-bundle/generation-distribution/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "distributionOutsidePluginRootAccepted"
			fixture:      "distributionOutsidePluginRootAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/plugin-bundle/generation-distribution/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "nonDeterministicGenerationAccepted"
			fixture:      "nonDeterministicGenerationAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/plugin-bundle/generation-distribution/checks"
		}
	},
	impl.#MakeBottomCheckPlan & {
		in: {
			name:         "runtimeExternalSourceLookupAccepted"
			fixture:      "runtimeExternalSourceLookupAccepted"
			checkSurface: "_negativeBottomChecks"
			checkFile:    "./contracts/plugin-bundle/generation-distribution/checks"
		}
	},
]

pluginBundleGenerationDistributionPlan: #PluginBundleGenerationPlan & {
	templateShape: "contracts/plugin-bundle/template/template.cue"
	sourceRoots: [
		"contracts/plugin-bundle/agent-context-resolver/src",
		"contracts/plugin-bundle/code-intel/src",
	]
	materializedRoots: sourceRoots
	emittedArtifacts: [
		{
			bundleID:         "agent-context-resolver"
			sourceRoot:       "contracts/plugin-bundle/agent-context-resolver/src"
			distributionRoot: ".codex/plugins/agent-context-resolver"
			runtimeFiles: ["manifest.json", "SKILL.md", "scripts/agent-context-resolver-hook", "scripts/resolve-agent-context"]
			lockEvidence: ["package.lock.json"]
			authorityBoundary: "projection-only"
		},
		{
			bundleID:         "code-intel"
			sourceRoot:       "contracts/plugin-bundle/code-intel/src"
			distributionRoot: ".codex/plugins/code-intel"
			runtimeFiles: ["manifest.json", "SKILL.md"]
			lockEvidence: []
			authorityBoundary: "projection-only"
		},
	]
	validation: {
		positiveExports: [
			"normalizedPluginBundleGenerationDistributionManifest",
			"pluginBundleGenerationDistributionValidationPlan",
			"pluginBundleGenerationDistributionCompletionReportContract",
		]
		negativeChecks: _bottomCheckNames
		forbiddenAttractors: [
			"generated packages as authority",
			"distribution outside .codex/plugins",
			"non-deterministic generation",
			"runtime external source checkout",
		]
		distributionDiffPolicy: "path-contained-reviewable"
	}
}

pluginBundleMaterializationPlan: #PluginBundleMaterializationProgram & {
	sourceAuthority: _repo.sourceAuthority
	planExport:      _repo.planExport
	materializer: {
		issue:                  84
		role:                   "idempotent projection writer"
		mustBeDeterministic:    true
		mustBeIdempotent:       true
		mustBePathContained:    true
		mustNotOwnPolicy:       true
		mustNotOwnAuthority:    true
		mustEmitReviewableDiff: true
	}
	targets: _materializationIssue & {
		materializerFunction:                #PluginBundleMaterializerFunction
		agentContextResolverMaterialization: #AgentContextResolverMaterializationSlice
	}
}

CrossRepoPluginBundleDistributionTarget: close({
	sourceBundle:     string & !=""
	sourceAuthority:  string & !=""
	targetRepository: string & !=""
	targetPath:       string & !=""
	distributionMode: "repo-local-runtime-projection" | "consumer-runtime-projection"
})

CrossRepoPluginBundleDistributionTargetMatrix: close({
	targets: [...CrossRepoPluginBundleDistributionTarget] & [_, ...]
	sourceAuthority: "contracts/plugin-bundle/generation-distribution"
	reviewBoundary:  "path-contained-reviewable"
})

normalizedCrossRepoPluginBundleDistributionManifest: close({
	issue: _crossRepoIssue
	distributionTargets: [
		{
			sourceBundle:     "agent-context-resolver"
			sourceAuthority:  "contracts/plugin-bundle/generation-distribution"
			targetRepository: "fatb4f/factory"
			targetPath:       ".codex/plugins/agent-context-resolver"
			distributionMode: "repo-local-runtime-projection"
		},
		{
			sourceBundle:     "agent-context-resolver"
			sourceAuthority:  "contracts/plugin-bundle/generation-distribution"
			targetRepository: "fatb4f/dotfiles"
			targetPath:       ".codex/plugins/agent-context-resolver"
			distributionMode: "consumer-runtime-projection"
		},
		{
			sourceBundle:     "code-intel"
			sourceAuthority:  "contracts/plugin-bundle/generation-distribution"
			targetRepository: "fatb4f/dotfiles"
			targetPath:       ".codex/plugins/code-intel"
			distributionMode: "consumer-runtime-projection"
		},
	]
	invariants: [
		"factory owns canonical plugin-bundle generation/distribution authority",
		"agent-context-resolver distributes to factory and dotfiles",
		"code-intel distributes to dotfiles only",
		"cross-repo promotions require reviewable, path-contained diffs",
	]
})

crossRepoPluginBundleDistributionValidationPlan: close({
	path: "contracts/plugin-bundle/generation-distribution"
	positive: [
		"cue vet ./contracts/plugin-bundle/generation-distribution",
		"cue export ./contracts/plugin-bundle/generation-distribution -e normalizedCrossRepoPluginBundleDistributionManifest",
		"cue export ./contracts/plugin-bundle/generation-distribution -e crossRepoPluginBundleDistributionValidationPlan",
		"cue export ./contracts/plugin-bundle/generation-distribution -e crossRepoPluginBundleDistributionCompletionReportContract",
	]
	negative: [
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.codeIntelDistributedToFactoryAccepted",
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.dotfilesSourceAuthorityAccepted",
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.outsidePluginRootAccepted",
		"! cue export ./contracts/plugin-bundle/generation-distribution/checks -e _negativeBottomChecks.unreviewedCrossRepoWriteAccepted",
	]
})

crossRepoPluginBundleDistributionCompletionReportContract: close({
	summary: [
		"canonical plugin-bundle generation/distribution now owns cross-repo targets",
		"issue 83 is an issue-local projection only",
		"negative checks bottom through the canonical plugin-bundle check surface",
	]
	canonicalFiles: [
		"contracts/plugin-bundle/generation-distribution/manifest.cue",
		"contracts/plugin-bundle/generation-distribution/checks/checks.cue",
	]
	issueFiles: [
		"contracts/issues/83/manifest.cue",
		"contracts/issues/83/checks/checks.cue",
	]
	validation:  crossRepoPluginBundleDistributionValidationPlan
	finalResult: "issue #83 tracks the plugin-bundle cross-repo target matrix"
})

_validation: impl.#MakeValidationPlan & {
	in: {
		path:              "contracts/plugin-bundle/generation-distribution"
		validBaselineExpr: "normalizedPluginBundleGenerationDistributionManifest"
		publicExpr:        "normalizedPluginBundleGenerationDistributionManifest"
		bottomChecks:      _bottomCheckNames
		checkFile:         "./contracts/plugin-bundle/generation-distribution/checks"
		checkSurface:      "_negativeBottomChecks"
		forbiddenPattern:  "[g]eneratedPackageAuthorityAccepted: true|[p]athContainedAccepted: false|[n]onDeterministicGenerationAccepted: true|[r]untimeExternalSourceLookupAccepted: true"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [for fixture in _negativeFixtures {fixture.out.id}]
		checks:   _bottomCheckNames
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
	plan:     pluginBundleGenerationDistributionPlan
	primitives: [for primitive in _primitives {primitive.out}]
	surfaces:         _surfaces.out
	negativeFixtures: negativePluginBundleGenerationDistributionFixtures
	bottomCheckPlans: [for plan in _bottomCheckPlans {plan.out}]
	generation: {
		templateAuthority: pluginBundleGenerationDistributionPlan.templateShape
		sourceRoots:       pluginBundleGenerationDistributionPlan.sourceRoots
		distributionRoots: [for artifact in pluginBundleGenerationDistributionPlan.emittedArtifacts {artifact.distributionRoot}]
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
normalizedPluginBundleGenerationDistributionAuthority:      normalizedPluginBundleGenerationDistributionManifest
pluginBundleMaterializationPlan:                            pluginBundleGenerationDistributionPlan
pluginBundleGenerationDistributionAuthorityPath:            "contracts/plugin-bundle/generation-distribution/manifest.cue"

_materializerFunction: #PluginBundleMaterializerFunction

_agentContextResolverMaterialization: #AgentContextResolverMaterializationSlice

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name:     "nonIdempotentMaterializerAccepted"
			violates: "materializer idempotence"
			refusal:  "materializer must converge to no diff on unchanged input"
			input: {
				idempotent: false
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "materializerOwnsPolicyAccepted"
			violates: "authority boundary"
			refusal:  "materializer consumes CUE authority but does not define bundle policy"
			input: {
				sourceAuthority:  "materializer-runtime"
				mustNotOwnPolicy: false
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "writeOutsidePluginRootAccepted"
			violates: "path containment"
			refusal:  "materializer writes stay under .codex/plugins/<bundle-id>"
			input: {
				writeRoot:     "contracts/plugin-bundle/generated"
				pathContained: false
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "lockEvidenceAuthorityAccepted"
			violates: "generated evidence boundary"
			refusal:  "lock evidence records generated state but is not source authority"
			input: {
				lockEvidence: {
					isAuthority: true
				}
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "dotfilesSourceAuthorityAccepted"
			violates: "consumer authority boundary"
			refusal:  "fatb4f/dotfiles receives generated runtime projection only"
			input: {
				targetRepository:          "fatb4f/dotfiles"
				sourceAuthority:           "fatb4f/dotfiles:.codex/plugins/agent-context-resolver"
				targetOwnsSourceAuthority: true
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "factoryCodeIntelWriteAccepted"
			violates: "agent-context-resolver-only target set"
			refusal:  "this slice materializes agent-context-resolver only; code-intel is not a factory target"
			input: {
				sourceBundle:     "code-intel"
				targetRepository: "fatb4f/factory"
				targetPath:       ".codex/plugins/code-intel"
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "outsideAgentContextResolverRootAccepted"
			violates: "path containment"
			refusal:  "agent-context-resolver writes stay under .codex/plugins/agent-context-resolver"
			input: {
				targetRepository: "fatb4f/dotfiles"
				targetPath:       ".codex/agent-context-resolver"
				pathContained:    false
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name:     "unreviewableDiffAccepted"
			violates: "review boundary"
			refusal:  "materialization must produce reviewable path-contained diffs in each target repository"
			input: {
				targetRepository: "fatb4f/dotfiles"
				reviewableDiff:   false
			}
		}
	},
]

negativePluginBundleMaterializationFixtures: {
	nonIdempotentMaterializerAccepted:       _negativeFixtures[0].out
	materializerOwnsPolicyAccepted:          _negativeFixtures[1].out
	writeOutsidePluginRootAccepted:          _negativeFixtures[2].out
	lockEvidenceAuthorityAccepted:           _negativeFixtures[3].out
	dotfilesSourceAuthorityAccepted:         _negativeFixtures[4].out
	factoryCodeIntelWriteAccepted:           _negativeFixtures[5].out
	outsideAgentContextResolverRootAccepted: _negativeFixtures[6].out
	unreviewableDiffAccepted:                _negativeFixtures[7].out
}

_materializationBottomCheckPlans: [
	for fixtureName in [
		"nonIdempotentMaterializerAccepted",
		"materializerOwnsPolicyAccepted",
		"writeOutsidePluginRootAccepted",
		"lockEvidenceAuthorityAccepted",
		"dotfilesSourceAuthorityAccepted",
		"factoryCodeIntelWriteAccepted",
		"outsideAgentContextResolverRootAccepted",
		"unreviewableDiffAccepted",
	] {
		impl.#MakeBottomCheckPlan & {
			in: {
				name:         fixtureName
				fixture:      fixtureName
				checkSurface: "_negativeBottomChecks"
				checkFile:    "./contracts/plugin-bundle/generation-distribution/checks"
			}
		}
	},
]

_materializationValidation: impl.#MakeValidationPlan & {
	in: {
		path:              "contracts/plugin-bundle/generation-distribution"
		validBaselineExpr: "normalizedPluginBundleMaterializationManifest"
		publicExpr:        "normalizedPluginBundleMaterializationManifest"
		bottomChecks: [for plan in _materializationBottomCheckPlans {plan.out.name}]
		checkFile:        "./contracts/plugin-bundle/generation-distribution/checks"
		checkSurface:     "_negativeBottomChecks"
		forbiddenPattern: "[i]dempotent: false|[d]eterministic: false|[p]athContained: false|[p]rojectionOnly: false|[i]sAuthority: true|[t]argetOwnsSourceAuthority: true|[m]aterializedIsAuthority: true|[g]eneratedPackageAuthority: true|[s]ourceAuthority: \"materializer-runtime\""
	}
}

_materializationCompletion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [for fixture in _negativeFixtures {fixture.out.id}]
		checks:   _materializationValidation.in.bottomChecks
		commands: _materializationValidation.out.commands
		evidence: [
			"issue-template constructor pattern",
			"generation-distribution authority exports pluginBundleMaterializationPlan",
			"agent-context-resolver target matrix includes fatb4f/factory and fatb4f/dotfiles",
			"materializer is idempotent, deterministic, path-contained, and projection-only",
		]
	}
}

_parentProgram: #PluginBundleMaterializationProgram & {
	sourceAuthority: _repo.sourceAuthority
	planExport:      _repo.planExport
	materializer: {
		issue:                  84
		role:                   "idempotent projection writer"
		mustBeDeterministic:    true
		mustBeIdempotent:       true
		mustBePathContained:    true
		mustNotOwnPolicy:       true
		mustNotOwnAuthority:    true
		mustEmitReviewableDiff: true
	}
	targets: _agentContextResolverMaterialization.targets
}

normalizedPluginBundleMaterializationManifest: {
	seed:                                _contractSeed
	repo:                                _repo
	issues:                              _issues
	workflow:                            _workflowIndex
	parentProgram:                       _parentProgram
	materializerFunction:                _materializerFunction
	agentContextResolverMaterialization: _agentContextResolverMaterialization
	primitives: [for primitive in _primitives {primitive.out}]
	surfaces:         _surfaces.out
	negativeFixtures: negativePluginBundleMaterializationFixtures
	bottomCheckPlans: [for plan in _materializationBottomCheckPlans {plan.out}]
}

pluginBundleMaterializationValidationPlan:           _materializationValidation.out
pluginBundleMaterializationCompletionReportContract: _materializationCompletion.out
