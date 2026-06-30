package issue

import impl "github.com/fatb4f/factory/.github/contracts/meta/impl"

_issue: {
	number: 90
	title:  "factory: define plugin layout and scaffold agent-context-resolver/code-intel"
	path:   ".github/ISSUE_TEMPLATE/contracts/issues/90/manifest.cue"
}

#FactoryPluginSliceInput: close({
	repository: string & !=""
	issueNumber: int
	contractAuthority: string & !=""
	generatorContract: string & !=""
	scaffoldAdapter: string & !=""
	projectionRoot: string & !=""
	generatedRoot: string & !=""
	targetBundles: [...close({
		pluginName: string & !=""
		canonicalRoot: string & !=""
		projectionRoot: string & !=""
		generatedRoot: string & !=""
	})] & [_, ...]
})

#GeneratorContractAssertion: close({
	id: string & !=""
	target: string & !=""
	requires: [...string & !=""] & [_, ...]
})

_slice: #FactoryPluginSliceInput & {
	repository: "fatb4f/factory"
	issueNumber: _issue.number
	contractAuthority: "contracts/plugin-bundle/src/manifest.cue"
	generatorContract: "contracts/plugin-bundle/src/manifest.cue"
	scaffoldAdapter: "contracts/plugin-bundle/src/adapters/scaffold-plugin-bundle"
	projectionRoot: "contracts/plugin-bundle/<plugin-name>/src"
	generatedRoot: "contracts/plugin-bundle/generated/<plugin-name>"
	targetBundles: [
		{
			pluginName: "agent-context-resolver"
			canonicalRoot: "contracts/agent-context-resolver/src"
			projectionRoot: "contracts/plugin-bundle/agent-context-resolver/src"
			generatedRoot: "contracts/plugin-bundle/generated/agent-context-resolver"
		},
		{
			pluginName: "code-intel"
			canonicalRoot: "contracts/code-intel/src"
			projectionRoot: "contracts/plugin-bundle/code-intel/src"
			generatedRoot: "contracts/plugin-bundle/generated/code-intel"
		},
	]
}

_workflowIndex: [
	{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
	{order: 2, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
	{order: 3, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
	{order: 4, id: "generator-contract-assertions", instantiateAt: "_generatorAssertions"},
	{order: 5, id: "validation-plan", instantiateAt: "_validation"},
	{order: 6, id: "completion-report-contract", instantiateAt: "_completion"},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name: "#FactoryPluginSliceInput"
			role: "issue-local contract input for plugin-bundle layout tightening"
			requiredFields: [
				"repository",
				"issueNumber",
				"contractAuthority",
				"generatorContract",
				"scaffoldAdapter",
				"projectionRoot",
				"generatedRoot",
				"targetBundles",
			]
			constraints: [
				"contract projection stays under contracts/plugin-bundle/<plugin-name>/src",
				"generated physical plugin projection stays under contracts/plugin-bundle/generated/<plugin-name>",
				"generated plugin projection is evidence only, not installation authority",
				"bottom checks are deferred; this slice records generator-contract assertions only",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name: "#GeneratorContractAssertion"
			role: "assertion that must be represented under the plugin-bundle generator contract CUE"
			requiredFields: ["id", "target", "requires"]
			constraints: [
				"assertions live in generator contract CUE before executable checks are added",
				"assertions describe generated layout boundaries without constructing bottom-check proofs",
			]
			closed: true
		}
	},
]

_generatorAssertions: [
	#GeneratorContractAssertion & {
		id: "generated-plugin-root-is-plugin-bundle-generated"
		target: _slice.generatorContract
		requires: [
			"define generated plugin projection root as contracts/plugin-bundle/generated/<plugin-name>",
			"reject generated plugin files under the contract projection output root",
			"reject repo-root plugin installation as generator output",
		]
	},
	#GeneratorContractAssertion & {
		id: "contract-projection-root-is-plugin-bundle-src"
		target: _slice.generatorContract
		requires: [
			"define contract projection root as contracts/plugin-bundle/<plugin-name>/src",
			"keep pluginBundleContract, pluginBundleValidationPlan, and pluginBundleCompletionReport as public projection exports",
		]
	},
	#GeneratorContractAssertion & {
		id: "checks-deferred-to-later-slice"
		target: _slice.generatorContract
		requires: [
			"do not add executable bottom-check packages in this slice",
			"record check intent as generator-contract assertions only",
		]
	},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#FactoryPluginSliceInput", "#GeneratorContractAssertion"]
		observed: ["_slice.targetBundles"]
		candidates: ["normalizedFactoryIssueManifest"]
		fixtures: ["negativeFactoryPluginFixtures"]
		checks: ["deferredBottomChecks"]
		publicExports: [
			"normalizedFactoryIssueManifest",
			"factoryIssueValidationPlan",
			"factoryIssueCompletionReportContract",
		]
	}
}

_negativeFixtures: [
	impl.#MakeNegativeFixture & {
		in: {
			name: "outRootConflatesContractAndGeneratedAccepted"
			violates: "contract output and generated plugin output must be separate planes"
			refusal: "generated physical plugin projection must be under contracts/plugin-bundle/generated, not under contract out"
			input: {
				pluginName: "code-intel"
				contractOut: "contracts/plugin-bundle/code-intel/src"
				generatedOut: "contracts/plugin-bundle/code-intel/src/plugins/code-intel"
				expectedGeneratedOut: "contracts/plugin-bundle/generated/code-intel"
			}
		}
	},
	impl.#MakeNegativeFixture & {
		in: {
			name: "repoRootPluginInstallAccepted"
			violates: "generator output must not claim repo-root installation authority"
			refusal: "repo-root plugin installation is outside this generated projection slice"
			input: {
				pluginName: "agent-context-resolver"
				generatedOut: "plugins/agent-context-resolver"
				expectedGeneratedOut: "contracts/plugin-bundle/generated/agent-context-resolver"
			}
		}
	},
]

negativeFactoryPluginFixtures: {
	outRootConflatesContractAndGeneratedAccepted: _negativeFixtures[0].out
	repoRootPluginInstallAccepted: _negativeFixtures[1].out
}

deferredBottomChecks: close({
	reason: "checks after generator-contract assertions"
	plannedFixtures: [for fixture in _negativeFixtures {fixture.out.id}]
})

_validation: close({
	kind: "validation-plan"
	commands: [
		"cd .github && cue vet ./ISSUE_TEMPLATE/contracts/issues/90",
		"cd .github && cue export ./ISSUE_TEMPLATE/contracts/issues/90 -e normalizedFactoryIssueManifest",
		"cd .github && cue export ./ISSUE_TEMPLATE/contracts/issues/90 -e factoryIssueValidationPlan",
		"cd .github && cue export ./ISSUE_TEMPLATE/contracts/issues/90 -e factoryIssueCompletionReportContract",
		"rg 'contracts/plugin-bundle/generated' ./contracts/plugin-bundle/src",
		"! rg 'root / \\\"plugins\\\"|root / \\\"\\.agents\\\"' ./contracts/plugin-bundle/src/adapters/scaffold-plugin-bundle",
	]
	deferredBottomChecks: true
})

_completion: close({
	kind: "completion-report-contract"
	requiredSections: [
		"summary",
		"generator contract assertions",
		"contract projection root",
		"generated plugin projection root",
		"target bundles",
		"validation",
		"deferred checks",
		"evidence",
	]
	expected: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces: _surfaces.out.publicExports
		fixtures: [for fixture in _negativeFixtures {fixture.out.id}]
		checks: ["deferredBottomChecks"]
		commands: _validation.commands
		evidence: [
			".github/contracts/meta/impl constructor surface",
			"issue 90 contract body",
			"plugin-bundle generator contract CUE",
			"scaffold adapter generated projection root",
		]
	}
})

normalizedFactoryIssueManifest: close({
	issue: _issue
	slice: _slice
	workflow: _workflowIndex
	primitives: [for item in _primitives {item.out}]
	generatorAssertions: _generatorAssertions
	surfaces: _surfaces.out
	negativeFixtures: negativeFactoryPluginFixtures
	deferredBottomChecks: deferredBottomChecks
})

factoryIssueValidationPlan: _validation
factoryIssueCompletionReportContract: _completion

// Compatibility aliases for the installed .github issue-template surface.
normalizedIssueTemplateManifest: normalizedFactoryIssueManifest
issueTemplateValidationPlan: factoryIssueValidationPlan
issueTemplateCompletionReportContract: factoryIssueCompletionReportContract
