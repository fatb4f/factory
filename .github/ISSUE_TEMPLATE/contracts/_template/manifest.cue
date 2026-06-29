package issue

_contractSeed: close({
	id:         "github-issue-template-agents-template"
	version:    "v0.1.0"
	owner:      "factory/contracts"
	idempotent: true
})

templateAuthority: close({
	agents:         ".github/ISSUE_TEMPLATE/contracts/_template/AGENTS.md"
	activeTemplate: ".github/ISSUE_TEMPLATE/contracts.md"
	template:       ".github/ISSUE_TEMPLATE/contracts/_template/issue-body.template.md"
})

issueBodyShape: close({
	outerMarkdown: "single fenced cue block"
	rootLabel:     "issue"
	requiredFields: [
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
})

normalizedIssueTemplateManifest: {
	seed:      _contractSeed
	authority: templateAuthority
	shape:     issueBodyShape
}

issueTemplateValidationPlan: {
	kind: "validation-plan"
	commands: [
		"test -f .github/ISSUE_TEMPLATE/contracts/_template/AGENTS.md",
		"test -f .github/ISSUE_TEMPLATE/contracts.md",
		"test -f .github/ISSUE_TEMPLATE/contracts/_template/issue-body.template.md",
	]
}

issueTemplateCompletionReportContract: {
	kind: "completion-report-contract"
	requiredSections: ["files changed", "issue template authority", "validation", "final result"]
}

normalizedConstructorWorkflowManifest:       normalizedIssueTemplateManifest
constructorWorkflowValidationPlan:           issueTemplateValidationPlan
constructorWorkflowCompletionReportContract: issueTemplateCompletionReportContract
