package dotfilespluginbundle

implementationSliceMaterializerSkillExtraction: {
	schema:  "factory.dotfiles-agent-context-resolver.implementation-slice-skill-extraction.v0"
	status:  "admitted"
	package: "dotfilespluginbundle"
	path:    "contracts/factory/plugin-bundle/dotfiles-agent-context-resolver"
	slice:   "implementation-slice-issue-materializer-skill-v0"

	source: {
		repo:   "github.com/fatb4f/factory"
		commit: "2c6d9f50924c92a0c2f21d127bf3ef8ca10c8852"
		issue:  44
		paths: [
			"contracts/issues/44/manifest.cue",
			"contracts/issues/44/normalized.cue",
			"contracts/issues/44/validation.cue",
			"contracts/issues/44/checks/checks.cue",
			"contracts/agent-context-resolver/implementation_slice_materializer.cue",
			"contracts/agent-context-resolver/implementation_slice_eval_projection.cue",
			"contracts/agent-context-resolver/implementation_slice_runner_result.cue",
			"contracts/agent-context-resolver/implementation_slice_constructor_inventory.cue",
			"contracts/agent-context-resolver/projections/codex/skills/resolve-agent-context/SKILL.md",
		]
	}

	authority: {
		owns: [
			"resolver skill projection for implementation-slice issue materialization",
			"plugin-bundle packaging reference to issue 44 workflow",
			"dotfiles skill materialization inventory",
		]
		doesNotOwn: [
			"contract.cuemod constructor semantics",
			"GitHub issue body authority",
			"runtime execution",
			"GitHub API authority",
			"manual generated artifact edits",
		]
	}

	workflow: {
		contractSeed: "GitHub issue body as transport-only compact implementation slice"
		constructorAuthority: "contracts/meta/impl"
		materializerAuthority: "contracts/agent-context-resolver"
		referenceIssue: "contracts/issues/44"
		checkSurface: "contracts/issues/44/checks/_negativeBottomChecks"
		projectedSkill: "contracts/agent-context-resolver/projections/codex/skills/resolve-agent-context/SKILL.md"
		targetSkill: ".codex/plugins/agent-context-resolver/SKILL.md"
	}

	models: [
		"#RawImplementationSliceIssue",
		"#ParsedImplementationSliceIssue",
		"#ImplementationSliceMaterialization",
		"#ImplementationSliceEvalObligations",
		"#ImplementationSliceEvalPlan",
		"#ImplementationSliceRunnerPlan",
		"#ClassifiedRunnerResult",
		"#IssueMaterializationCandidate",
	]

	publicSurfaces: [
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

	negativeFixtures: [
		"routeOnlyPacket",
		"missingContractPath",
		"staticEvalPlan",
		"missingNegativeCheckExpression",
		"anyNonzeroAsPass",
	]

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
	}

	forbiddenAttractors: [
		"route-only packet as materialization candidate",
		"missing contract.path accepted",
		"static eval plan detached from loaded issue",
		"missing negative check expression accepted",
		"any nonzero runner exit classified as pass",
		"generated artifacts as authority",
		"adapter output as authority",
		"GitHub issue body as authority",
	]

	acceptance: [
		"resolver skill includes implementation-slice materializer workflow",
		"plugin-bundle reports issue 44 as the source workflow reference",
		"target skill inventory includes .codex/plugins/agent-context-resolver/SKILL.md",
		"negative bottom-check names are preserved",
		"issue body remains transport-only",
	]
}
