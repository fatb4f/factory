package issue

import impl "github.com/fatb4f/factory/cuemod/contracts/meta/impl"

_contractSeed: close({
	id:         "contract-template-workflow"
	version:    "v0.1.0"
	owner:      "factory/cuemod"
	idempotent: true
})

#ContractTemplateWorkflowInput: close({
	repository:         string & !=""
	module:             string & !=""
	constructorLibrary: string & !=""
	templateRoot:       string & !=""
	templatePath:       string & !=""
	publicExports: close({
		manifest:         string & !=""
		validationPlan:   string & !=""
		completionReport: string & !=""
	})
})

_repo: #ContractTemplateWorkflowInput & {
	repository:         "fatb4f/factory"
	module:             "github.com/fatb4f/factory/cuemod"
	constructorLibrary: "contracts/meta/impl"
	templateRoot:       ".github/ISSUE_TEMPLATE/contracts"
	templatePath:       ".github/ISSUE_TEMPLATE/contracts/_template/manifest.cue"
	publicExports: {
		manifest:         "normalizedContractTemplateWorkflowManifest"
		validationPlan:   "contractTemplateWorkflowValidationPlan"
		completionReport: "contractTemplateWorkflowCompletionReportContract"
	}
}

_template: close({
	title: "template"
	path:  _repo.templatePath
})

validContractTemplateWorkflowSeed: close({
	seed:                 _contractSeed
	template:             _template
	repository:           _repo.repository
	module:               _repo.module
	constructorLibrary:   _repo.constructorLibrary
	templateRoot:         _repo.templateRoot
	templatePath:         _repo.templatePath
	repoLocalOverlay:     true
	constructorCallsOnly: true
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
			name:           "#ContractTemplateWorkflowInput"
			role:           "repo-local input contract for template workflow installation"
			requiredFields: ["repository", "module", "constructorLibrary", "templateRoot", "templatePath", "publicExports"]
			constraints: [
				"repo identity is input data",
				"module path is repo-local",
				"public export names are deterministic",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name:           "validContractTemplateWorkflowSeed"
			role:           "normalized seed manifest for a repository template workflow"
			requiredFields: ["seed", "template", "repository", "module", "constructorLibrary", "templateRoot", "templatePath"]
			constraints: [
				"constructor bodies stay in the repo-local implementation package",
				"generated artifacts are evidence only",
			]
			closed: true
		}
	},
]

_negativeFixtures: []
negativeContractTemplateWorkflowFixtures: {}
_bottomCheckPlans: []

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["validContractTemplateWorkflowSeed"]
		observed:   ["_repo", "_template"]
		candidates: ["normalizedContractTemplateWorkflowManifest"]
		fixtures:   ["negativeContractTemplateWorkflowFixtures"]
		checks:     ["_negativeBottomChecks"]
		publicExports: [
			_repo.publicExports.manifest,
			_repo.publicExports.validationPlan,
			_repo.publicExports.completionReport,
		]
	}
}

_negativeBottomChecks: {}

_validation: impl.#MakeValidationPlan & {
	in: {
		path:              "\(_repo.templateRoot)/_template"
		validBaselineExpr: "validContractTemplateWorkflowSeed"
		publicExpr:        _repo.publicExports.manifest
		bottomChecks:      []
		checkFile:         "./\(_repo.templateRoot)/_template/checks"
		checkSurface:      "_negativeBottomChecks"
		forbiddenPattern:  "#RepoIssueTemplateInput|validIssueTemplateSeed|normalizedIssueTemplateManifest"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces:  _surfaces.out.publicExports
		fixtures:  []
		checks:    []
		commands:  _validation.out.commands
		evidence:  ["repo-local input", "repo-local constructor import", "deterministic public exports"]
	}
}

normalizedContractTemplateWorkflowManifest: {
	seed:              _contractSeed
	repo:              _repo
	template:          _template
	workflow:          _workflowIndex
	validBaseline:     validContractTemplateWorkflowSeed
	primitives:        [for item in _primitives {item.out}]
	surfaces:          _surfaces.out
	negativeFixtures:  negativeContractTemplateWorkflowFixtures
	bottomCheckPlans:  []
}

contractTemplateWorkflowValidationPlan:           _validation.out
contractTemplateWorkflowCompletionReportContract: _completion.out
