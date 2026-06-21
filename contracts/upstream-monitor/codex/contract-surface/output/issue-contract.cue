package contractsurfaceoutput

#IssueUpdate: {
	target_repo: "fatb4f/factory"
	target_issue: int
	impact_decision: "note" | "contract-update" | "blocking-gate"
	upstream_evidence_summary: string
	local_contract_impact: string
	suggested_local_targets: [...string]
}

issue_update_contract: {
	template: "contracts/upstream-monitor/codex/contract-surface/output/issue-update-template.md"
	enabled_initial_gate: false
	allowed_targets: []
}
