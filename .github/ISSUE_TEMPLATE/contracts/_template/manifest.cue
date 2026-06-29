package issue

import impl "github.com/fatb4f/factory/cuemod/contracts/meta/impl"

_contractSeed: close({
	id:         "github-issue-template-single-cue-block"
	version:    "v0.1.0"
	owner:      "factory/cuemod"
	idempotent: true
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
			]
			closed: true
		}
	},
]

negativeIssueTemplateFixtures: {
	extraMarkdownHeading: {id: "extraMarkdownHeading"}
	missingCueFence:     {id: "missingCueFence"}
	missingTopLevelIssue: {id: "missingTopLevelIssue"}
}

_negativeFixtures: [
	negativeIssueTemplateFixtures.extraMarkdownHeading,
	negativeIssueTemplateFixtures.missingCueFence,
	negativeIssueTemplateFixtures.missingTopLevelIssue,
]

_bottomCheckPlans: [
	{name: "extraMarkdownHeadingRejected", fixture: negativeIssueTemplateFixtures.extraMarkdownHeading.id, checkSurface: "_negativeBottomChecks", checkFile: "./.github/ISSUE_TEMPLATE/contracts/_template/checks/body_shape.cue"},
	{name: "missingCueFenceRejected", fixture: negativeIssueTemplateFixtures.missingCueFence.id, checkSurface: "_negativeBottomChecks", checkFile: "./.github/ISSUE_TEMPLATE/contracts/_template/checks/body_shape.cue"},
	{name: "missingTopLevelIssueRejected", fixture: negativeIssueTemplateFixtures.missingTopLevelIssue.id, checkSurface: "_negativeBottomChecks", checkFile: "./.github/ISSUE_TEMPLATE/contracts/_template/checks/body_shape.cue"},
]

_surfaces: impl.#MakeSurfaceSet & {
	in: {
		admissible: ["#IssueTemplateCueBlock", "#IssueBody"]
		observed:   ["issueTemplateYaml", "issueBodyFixture"]
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
		forbiddenPattern:  "^###|```json|```yaml"
	}
}

_completion: impl.#MakeCompletionReport & {
	in: {
		primitives: [for primitive in _primitives {primitive.out.name}]
		surfaces:  _surfaces.out.publicExports
		fixtures:  [for fixture in _negativeFixtures {fixture.id}]
		checks:    _validation.in.bottomChecks
		commands:  _validation.out.commands
		evidence:  ["single cue fence", "top-level issue object", "issue #44 shape parity"]
	}
}

normalizedIssueTemplateManifest: {
	seed:             _contractSeed
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
