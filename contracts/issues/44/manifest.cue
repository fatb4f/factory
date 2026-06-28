package issue44

import impl "github.com/fatb4f/contract.cuemod/contracts/meta/impl"

import resolver "github.com/fatb4f/contract.cuemod/contracts/plugin-bundle/agent-context-resolver/src:agentcontextresolver"

#Issue44Manifest: close({
	issue: 44
	title: "cue: implement agent-context-resolver implementation-slice issue materializer"
	tracking: {
		parent: 28
		dependsOn: [59]
		blocks: [42, 23, 13]
		manifestPath: "contracts/issues/44/manifest.cue"
	}
	template: {
		source: ".github/ISSUE_TEMPLATE/cue-implementation-slice.md"
		workflow: "docs/codex-manifest-slice-workflow.md"
		constructorLayering: _constructorLayering
	}
	instantiation: {
		target: {
			contractPath: "contracts/agent-context-resolver"
			package: "resolver"
			slice: "implementation-slice-issue-materializer"
		}
		authority: {
			constructors: "contracts/meta/impl"
			issueManifest: "contracts/issues/44/manifest.cue"
			checkSurface: "contracts/issues/44/checks"
			targetContract: "contracts/agent-context-resolver"
			githubIssueBody: "transport-only"
			tools: "evidence-only"
			generatedArtifacts: "evidence-only"
		}
		implement: [
			"raw implementation-slice issue observation",
			"parsed implementation-slice issue candidate",
			"CUE-loaded issue materialization candidate",
			"issue-specific eval obligation projection",
			"issue-specific eval-plan projection",
			"issue-specific runner-plan projection",
			"classified runner-result evidence",
			"issue-local negative fixtures and bottom-check proofs",
		]
		notImplement: [
			"VCS mutation",
			"downstream effect application",
			"full CI orchestration",
			"broad resolver state-machine redesign",
			"GitHub API authority",
			"Go wrapper",
			"MCP transport",
			"generated artifacts as evidence-only outputs",
		]
		models: _modelNames
		publicExports: [
			"implementationSliceIssueBaseline",
			"implementationSliceMaterializationReport",
			"implementationSliceEvalPlan",
			"implementationSliceRunnerPlan",
			"implementationSliceFeedbackShape",
			"implementationSliceConstructorInventory",
			"publicContract",
			"validationPlan",
			"completionReportContract",
		]
		files: {
			issue: [
				"contracts/issues/44/manifest.cue",
				"contracts/issues/44/normalized.cue",
				"contracts/issues/44/validation.cue",
				"contracts/issues/44/checks/checks.cue",
			]
			contract: [
				"contracts/agent-context-resolver/implementation_slice_materializer.cue",
				"contracts/agent-context-resolver/implementation_slice_eval_projection.cue",
				"contracts/agent-context-resolver/implementation_slice_runner_result.cue",
				"contracts/agent-context-resolver/fixtures.cue",
				"contracts/agent-context-resolver/checks.cue",
				"contracts/agent-context-resolver/checks_test.cue",
			]
			adapters: [
				"tools/agent-context-resolver/parse-implementation-slice-issue",
				"tools/agent-context-resolver/materialize-implementation-slice",
				"tools/hooks/run-eval-plan.sh",
			]
			generatedEvidence: ["generated/agent-context-resolver/issues/.gitkeep"]
		}
		negativeFixtures: _negativeNames
		validation: {
			positive: [
				"cue vet ./contracts/issues/44",
				"cue export ./contracts/issues/44 -e publicContract",
				"cue export ./contracts/issues/44 -e validationPlan",
				"cue export ./contracts/issues/44 -e completionReportContract",
				"cue vet ./contracts/agent-context-resolver",
				"cue export ./contracts/agent-context-resolver -e implementationSliceIssueBaseline",
				"cue export ./contracts/agent-context-resolver -e implementationSliceMaterializationReport",
				"cue export ./contracts/agent-context-resolver -e implementationSliceEvalPlan",
				"cue export ./contracts/agent-context-resolver -e implementationSliceRunnerPlan",
			]
			negative: [
				"! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.routeOnlyPacket'",
				"! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.missingContractPath'",
				"! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.staticEvalPlan'",
				"! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.missingNegativeCheckExpression'",
				"! cue export ./contracts/issues/44/checks -e '_negativeBottomChecks.anyNonzeroAsPass'",
			]
			forbiddenSearch: "! rg '\(targetWord):\\s*\(topWord)|\(inputWord):\\s*\(topWord)|\(exprWord):|\(invalidWord): true|\(operatorWord)\(truthWord)\(flagWord)|\(inlineWord) constructor|\(genWord).*\(authWord)|\(expectedWord)\(bottomOnlyWords)|\(anyNonzeroWords)\(passWord)|\(staticBaselineWords)\(evalPlanWords)|\(routeOnlyWords)\(resolutionWord)' ./contracts/issues/44 ./contracts/agent-context-resolver"
		}
		completion: {
			requiredSections: [
				"files changed",
				"constructs instantiated",
				"slice-specific data implemented",
				"public eval surfaces",
				"negative checks",
				"runner classification",
				"validation commands",
				"final result",
			]
		}
	}
})

validBaseline: #Issue44Manifest

_constructorInventory: impl.constructorCatalog

_modelNames: [
	"#RawImplementationSliceIssue",
	"#ParsedImplementationSliceIssue",
	"#ImplementationSliceMaterialization",
	"#ImplementationSliceEvalObligations",
	"#ImplementationSliceEvalPlan",
	"#ImplementationSliceRunnerPlan",
	"#ClassifiedRunnerResult",
	"#IssueMaterializationCandidate",
]

_constructorLayering: [
	{order: 1, id: "#MakePrimitive", constructor: "impl.#MakePrimitive", instantiateAt: "_primitives"},
	{order: 2, id: "#MakeObservedSurface", constructor: "impl.#MakeObservedSurface", instantiateAt: "_observed"},
	{order: 3, id: "#MakeAdmissibleSurface", constructor: "impl.#MakeAdmissibleSurface", instantiateAt: "_admissible"},
	{order: 4, id: "#MakePredicateSet", constructor: "impl.#MakePredicateSet", instantiateAt: "_predicates"},
	{order: 5, id: "#MakePromotionCandidate", constructor: "impl.#MakePromotionCandidate", instantiateAt: "_promotion"},
	{order: 6, id: "#MakeSurfaceSet", constructor: "impl.#MakeSurfaceSet", instantiateAt: "_surfaces"},
	{order: 7, id: "#MakeNegativeFixture", constructor: "impl.#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
	{order: 8, id: "#MakeBottomCheckPlan", constructor: "impl.#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
	{order: 9, id: "#MakeBottomCheckProof", constructor: "impl.#MakeBottomCheckProof", instantiateAt: "checks/_negativeBottomChecks"},
	{order: 10, id: "#MakeValidationPlan", constructor: "impl.#MakeValidationPlan", instantiateAt: "_validation"},
	{order: 11, id: "#MakeCompletionReport", constructor: "impl.#MakeCompletionReport", instantiateAt: "_completion"},
]

_primitives: [
	for _, modelName in _modelNames {
		(impl.#MakePrimitive & {
			in: {
				name: modelName
				role: "issue 44 implementation-slice materializer model"
				requiredFields: ["issue-specific authority", "checkable exported surface"]
				constraints: ["model is owned by contracts/agent-context-resolver"]
			}
		})
	}
]

_observed: impl.#MakeObservedSurface & {
	in: {
		name: "#RawImplementationSliceIssue"
		role: "observed issue transport payload before contract promotion"
		factFields: ["number", "title", "body", "state", "labels"]
		constraints: ["transport observations do not become authority"]
	}
}

targetWord: "target"
topWord: "_"
inputWord: "input"
exprWord: "expression"
invalidWord: "isInvalid"
operatorWord: "operator"
truthWord: "Truth"
flagWord: "Flag"
inlineWord: "inline"
genWord: "generated"
authWord: "authority"
expectedWord: "expected"
bottomOnlyWords: "BottomOnly"
anyNonzeroWords: "anyNonzero"
passWord: "Pass"
staticBaselineWords: "staticBaseline"
evalPlanWords: "EvalPlan"
routeOnlyWords: "routeOnly"
resolutionWord: "Resolution"

_admissible: impl.#MakeAdmissibleSurface & {
	in: {
		name: "#IssueMaterializationCandidate"
		role: "admissible materialization candidate with parsed and loaded issue evidence"
		observedSurface: _observed.out.name
		requiredFields: ["parsedIssue", "loadedIssue", "predicates"]
		rejectedFields: _negativeNames
		closed: true
	}
}

_predicates: impl.#MakePredicateSet & {
	in: {
		name: "#IssueMaterializationPredicates"
		role: "derived checks for materializer promotion"
		observedSurface: _observed.out.name
		admissibleSurface: _admissible.out.name
		derivedPredicates: [
			"requiresParsedIssue",
			"requiresLoadedIssue",
			"evalPlanDerivedFromLoadedIssue",
			"runnerPlanDerivedFromEvalPlan",
			"expectedFailureClassified",
			"negativeSelectorsResolve",
		]
		operatorSupplied: false
	}
}

_promotion: impl.#MakePromotionCandidate & {
	in: {
		name: "#ImplementationSliceMaterialization"
		role: "promoted CUE-loaded issue materialization"
		observedSurface: _observed.out.name
		admissibleSurface: _admissible.out.name
		predicateSet: _predicates.out.name
		controlPredicates: _predicates.out.derivedPredicates
		admissibilityEvidence: ["parsed issue", "loaded issue", "derived eval plan", "classified runner plan"]
		closed: true
	}
}

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: [_admissible.out.name, _promotion.out.name]
		observed: [_observed.out.name, "implementationSliceIssueBaseline"]
		candidates: ["implementationSliceMaterializationReport", "implementationSliceEvalPlan", "implementationSliceRunnerPlan"]
		fixtures: [for _, name in _negativeNames {"negativeFixtures.\(name)"}]
		checks: [for _, name in _negativeNames {"_negativeBottomChecks.\(name)"}]
		publicExports: validBaseline.instantiation.publicExports
	}
}

_negativeNames: [
	"routeOnlyPacket",
	"missingContractPath",
	"staticEvalPlan",
	"missingNegativeCheckExpression",
	"anyNonzeroAsPass",
]

_negativeFixtures: [
	for _, fixtureName in _negativeNames {
		(impl.#MakeNegativeFixture & {
			in: {
				name: fixtureName
				violates: "issue materialization admissibility"
				refusal: "reject malformed implementation-slice materialization candidate"
				input: resolver.negativeFixtures[fixtureName].input
			}
		}).out
	}
]

negativeFixtures: {
	for i, fixtureName in _negativeNames {
		"\(fixtureName)": _negativeFixtures[i]
	}
}

negativeFixtureExports: negativeFixtures

_bottomCheckPlans: [
	for _, checkName in _negativeNames {
		(impl.#MakeBottomCheckPlan & {
			in: {
				name: checkName
				fixture: "negativeFixtures.\(checkName)"
				checkSurface: "_negativeBottomChecks"
				checkFile: "./contracts/issues/44/checks"
			}
		}).out
	}
]

_validation: impl.#MakeValidationPlan & {
	in: {
		path: "contracts/issues/44"
		validBaselineExpr: "validBaseline"
		publicExpr: "publicContract"
		bottomChecks: _negativeNames
		checkFile: "./contracts/issues/44/checks"
		checkSurface: "_negativeBottomChecks"
		forbiddenPattern: validBaseline.instantiation.validation.forbiddenSearch
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for _, primitive in _primitives {primitive.out.name}]
		surfaces: validBaseline.instantiation.publicExports
		fixtures: [for _, name in _negativeNames {"negativeFixtures.\(name)"}]
		checks: [for _, name in _negativeNames {"_negativeBottomChecks.\(name)"}]
		commands: [
			for _, command in validBaseline.instantiation.validation.positive {command},
			for _, command in validBaseline.instantiation.validation.negative {command},
		]
		evidence: ["issue 44 manifest", "resolver materializer exports", "issue-local bottom checks", "runner classification contract"]
	}
}
