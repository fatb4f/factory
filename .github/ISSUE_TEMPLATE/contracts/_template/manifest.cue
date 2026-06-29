package issue

import impl "github.com/fatb4f/factory/cuemod/contracts/meta/impl"

_contractSeed: close({
	id:         "constructor-workflow-index"
	version:    "v0.1.0"
	owner:      "factory/cuemod"
	idempotent: true
})

_workflowIndex: [
	{order: 1, id: "#MakePrimitive"},
	{order: 2, id: "#MakeSurfaceSet"},
	{order: 3, id: "#MakeNegativeFixture"},
	{order: 4, id: "#MakeBottomCheckPlan"},
	{order: 5, id: "#MakeValidationPlan"},
	{order: 6, id: "#MakeCompletionReport"},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name:           "#ConstructorWorkflowStep"
			role:           "ordered constructor workflow entry"
			requiredFields: ["order", "id"]
			constraints: [
				"entries declare constructor order and constructor id only",
				"entries do not carry block target terms",
				"entries do not generate repository, template, or baseline seed wrapper terms",
			]
			closed: true
		}
	},
]

_negativeFixtures: []
negativeConstructorWorkflowFixtures: {}
_bottomCheckPlans: []

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#ConstructorWorkflowStep"]
		observed:   ["_workflowIndex"]
		candidates: ["normalizedConstructorWorkflowManifest"]
		fixtures:   ["negativeConstructorWorkflowFixtures"]
		checks:     ["_negativeBottomChecks"]
		publicExports: [
			"normalizedConstructorWorkflowManifest",
			"constructorWorkflowValidationPlan",
			"constructorWorkflowCompletionReportContract",
		]
	}
}

_negativeBottomChecks: {}

_validation: impl.#MakeValidationPlan & {
	in: {
		path:              "./.github/ISSUE_TEMPLATE/contracts/_template"
		validBaselineExpr: "_workflowIndex"
		publicExpr:        "normalizedConstructorWorkflowManifest"
		bottomChecks:      []
		checkFile:         "./.github/ISSUE_TEMPLATE/contracts/_template/checks"
		checkSurface:      "_negativeBottomChecks"
		forbiddenPattern:  "[i]nstantiateAt|#ContractTemplateWorkflow[I]nput|validContractTemplateWorkflow[S]eed|_[r]epo|_[t]emplate|repoLocal[O]verlay|constructorCalls[O]nly|template[P]ath|template[R]oot"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces:  _surfaces.out.publicExports
		fixtures:  []
		checks:    []
		commands:  _validation.out.commands
		evidence:  ["constructor workflow order", "constructor ids only", "no block target terms"]
	}
}

normalizedConstructorWorkflowManifest: {
	seed:              _contractSeed
	workflow:          _workflowIndex
	primitives:        [for item in _primitives {item.out}]
	surfaces:          _surfaces.out
	negativeFixtures:  negativeConstructorWorkflowFixtures
	bottomCheckPlans:  []
}

constructorWorkflowValidationPlan:           _validation.out
constructorWorkflowCompletionReportContract: _completion.out
