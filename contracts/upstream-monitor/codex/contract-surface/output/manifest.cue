package contractsurfaceoutput

// source: contracts/upstream-monitor/codex/contract-surface/output/manifest.cue
#IssueUpdate: {
	target_repo:               "fatb4f/factory"
	target_issue:              int
	impact_decision:           "note" | "contract-update" | "blocking-gate"
	upstream_evidence_summary: string
	local_contract_impact:     string
	suggested_local_targets: [...string]
}

issue_update_contract: {
	template:             "contracts/upstream-monitor/codex/contract-surface/output/issue-update-template.md"
	enabled_initial_gate: false
	allowed_targets: []
}

// source: contracts/upstream-monitor/codex/contract-surface/output/manifest.cue
#Severity: "critical" | "high" | "note" | "none"

#ReportItem: {
	title:    string
	severity: #Severity
	classification: [...string]
	impact_decision:        "note" | "contract-update" | "blocking-gate" | "none"
	local_contract_impact?: string
	suggested_local_targets?: [...string]
	tracked_issue_refs?: [...int]
}

#ImpactReport: {
	resolved_commit_sha: string
	critical: [...#ReportItem]
	high: [...#ReportItem]
	notes: [...#ReportItem]
	no_local_action: [...#ReportItem]
}

report_output_contract: {
	path:                 "contracts/upstream-monitor/codex/contract-surface/reports/latest.md"
	template:             "contracts/upstream-monitor/codex/contract-surface/output/report-template.md"
	enabled_initial_gate: false
}
