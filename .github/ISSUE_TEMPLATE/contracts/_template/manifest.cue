package issue

import impl "github.com/fatb4f/factory/contracts/meta/impl"

_contractSeed: close({
	id:         "github-issue-template-single-cue-block"
	version:    "v0.1.0"
	owner:      "factory/contracts"
	idempotent: true
})

cueModule: close({
	path:   "cue.mod"
	module: "github.com/fatb4f/factory"
})

issueBodyShape: close({
	fenceLanguage: "cue"
	rootLabel:     "issue"
	outerMarkdown: "single fenced cue block"
	requiredIssueFields: [
		"id",
		"kind",
		"repo",
		"number",
		"title",
		"template",
		"tracking",
		"goal",
		"intent",
		"authorityRoot",
		"authoritySplit",
		"targetSurfaces",
		"workflow",
		"boundaries",
		"closure",
		"validation",
		"completionReport",
	]
	requiredTemplateFields: ["name", "root", "workflow", "manifest", "checks", "import"]
	requiredWorkflowFields: ["order", "id", "instantiateAt"]
})

issueTemplateYaml: close({
	path:       ".github/ISSUE_TEMPLATE/contracts.yml"
	fieldCount: 1
	fieldType:  "textarea"
	fieldID:    "issue"
	render:     issueBodyShape.fenceLanguage
	module:     cueModule.module
	import:     "github.com/fatb4f/factory/contracts/meta/impl"
})

issueBodyFixture: close({
	path: ".github/ISSUE_TEMPLATE/contracts/_template/fixtures/issue-body.md"
})

_workflowIndex: [
	{order: 1, id: "#MakePrimitive", instantiateAt: "_primitives"},
	{order: 2, id: "#MakeSurfaceSet", instantiateAt: "_surfaces"},
	{order: 3, id: "#MakeNegativeFixture", instantiateAt: "_negativeFixtures"},
	{order: 4, id: "#MakeBottomCheckPlan", instantiateAt: "_bottomCheckPlans"},
	{order: 5, id: "#MakeBottomCheckProof", instantiateAt: "checks/_negativeBottomChecks"},
	{order: 6, id: "#MakeValidationPlan", instantiateAt: "_validation"},
	{order: 7, id: "#MakeCompletionReport", instantiateAt: "_completion"},
]

_primitives: [
	impl.#MakePrimitive & {
		in: {
			name:           "#IssueTemplateCueBlock"
			role:           "single fenced CUE issue body contract"
			requiredFields: ["fenceLanguage", "rootLabel", "outerMarkdown", "requiredIssueFields"]
			constraints: [
				"submitted issue bodies are one cue fence only",
				"the fenced value contains one top-level issue object",
				"imports resolve through root cue.mod only",
			]
			closed: true
		}
	},
	impl.#MakePrimitive & {
		in: {
			name:           "#IssueBody"
			role:           "top-level issue object shape mirrored from dotfiles issue #44"
			requiredFields: issueBodyShape.requiredIssueFields
			constraints: [
				"template metadata is carried under issue.template",
				"workflow entries preserve order, id, and instantiateAt shape",
				"no alternate module path is admitted as an import root",
			]
			closed: true
		}
	},
]

negativeIssueTemplateFixtures: {
	extraMarkdownHeading:     {id: "extraMarkdownHeading"}
	missingCueFence:         {id: "missingCueFence"}
	missingTopLevelIssue:    {id: "missingTopLevelIssue"}
	alternateModuleRoot:     {id: "alternateModuleRoot"}
}

_negativeFixtures: [
	negativeIssueTemplateFixtures.extraMarkdownHeading,
	negativeIssueTemplateFixtures.missingCueFence,
	negativeIssueTemplateFixtures.missingTopLevelIssue,
	negativeIssueTemplateFixtures.alternateModuleRoot,
]

_bottomCheckPlans: [
	{name: "extraMarkdownHeadingRejected", fixture: negativeIssueTemplateFixtures.extraMarkdownHeading.id, checkSurface: "_negativeBottomChecks", checkFile: "./.github/ISSUE_TEMPLATE/contracts/_template/checks/body_shape.cue"},
	{name: "missingCueFenceRejected", fixture: negativeIssueTemplateFixtures.missingCueFence.id, checkSurface: "_negativeBottomChecks", checkFile: "./.github/ISSUE_TEMPLATE/contracts/_template/checks/body_shape.cue"},
	{name: "missingTopLevelIssueRejected", fixture: negativeIssueTemplateFixtures.missingTopLevelIssue.id, checkSurface: "_negativeBottomChecks", checkFile: "./.github/ISSUE_TEMPLATE/contracts/_template/checks/body_shape.cue"},
	{name: "alternateModuleRootRejected", fixture: negativeIssueTemplateFixtures.alternateModuleRoot.id, checkSurface: "_negativeBottomChecks", checkFile: "./.github/ISSUE_TEMPLATE/contracts/_template/checks/module_root.cue"},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#IssueTemplateCueBlock", "#IssueBody"]
		observed:   ["cueModule", "issueTemplateYaml", "issueBodyFixture"]
		candidates: ["normalizedIssueTemplateManifest"]
		fixtures:   ["negativeIssueTemplateFixtures"]
		checks:     ["_negativeBottomChecks"]
		publicExports: [
			"normalizedIssueTemplateManifest",
			"issueTemplateValidationPlan",
			"issueTemplateCompletionReportContract",
			"normalizedConstructorWorkflowManifest",
			"constructorWorkflowValidationPlan",
			"constructorWorkflowCompletionReportContract",
		]
	}
}

_validation: impl.#MakeValidationPlan & {
	in: {
		path:              "./.github/ISSUE_TEMPLATE/contracts/_template"
		validBaselineExpr: "issueBodyShape"
		publicExpr:        "normalizedIssueTemplateManifest"
		bottomChecks:      [for plan in _bottomCheckPlans {plan.name}]
		checkFile:         "./.github/ISSUE_TEMPLATE/contracts/_template/checks"
		checkSurface:      "_negativeBottomChecks"
		forbiddenPattern:  "github\\.com/fatb4f/factory/[c]ue[m]od|```[j]son|```[y]aml"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces:  _surfaces.out.publicExports
		fixtures:  [for fixture in _negativeFixtures {fixture.id}]
		checks:    _validation.in.bottomChecks
		commands:  _validation.out.commands
		evidence:  ["root cue.mod module", "single cue fence", "top-level issue object", "issue #44 shape parity"]
	}
}

normalizedIssueTemplateManifest: {
	seed:             _contractSeed
	cueModule:        cueModule
	shape:            issueBodyShape
	template:         issueTemplateYaml
	fixture:          issueBodyFixture
	workflow:         _workflowIndex
	primitives:       [for item in _primitives {item.out}]
	surfaces:         _surfaces.out
	negativeFixtures: negativeIssueTemplateFixtures
	bottomCheckPlans: _bottomCheckPlans
}

issueTemplateValidationPlan:           _validation.out
issueTemplateCompletionReportContract: _completion.out

// Compatibility exports for existing constructor-workflow callers.
normalizedConstructorWorkflowManifest:       normalizedIssueTemplateManifest
constructorWorkflowValidationPlan:           issueTemplateValidationPlan
constructorWorkflowCompletionReportContract: issueTemplateCompletionReportContract
