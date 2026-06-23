package factory

issue28Relocation: {
	id: "factory.issue-28.location-correction"

	status: "relocated"
	authority: false

	priorDraftLocation:     "contracts/factory/**"
	correctedAuthorityRoot: "contracts/agent-context-resolver/**"
	correctedRecord:        "contracts/agent-context-resolver/issue_28.cue"

	reason: "Issue #28 was drafted against contracts/factory/** by mistake. The active contract authority is resolver-local. This factory-local file is retained only as a non-authoritative relocation marker."

	mustNotExportAs: [
		"issue",
		"promotionGate",
		"closureReport",
	]

	mustNotDecide: [
		"resolver hook/template/eval authority",
		"resolver runner plan admissibility",
		"resolver-local closure",
	]
}
