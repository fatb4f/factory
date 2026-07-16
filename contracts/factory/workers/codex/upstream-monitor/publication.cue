package upstreammonitor

#IssueTarget: close({
	repo: "fatb4f/factory"
	number: int & >0
	minimumImpact: "note" | "contract-update" | "blocking-gate"
})

upstreamCodexPublicationPlan: close({
	report: close({
		runPattern: "contracts/upstream-monitor/codex/contract-surface/reports/runs/<run_id>.codex-impact.md"
		latestPath: "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md"
	})
	evidence: close({
		runPattern: "contracts/upstream-monitor/codex/contract-surface/evidence/runs/<run_id>.codex-impact.report.json"
		latestPath: "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json"
	})
	issueTargets: [string]: #IssueTarget
	writeOrder: ["report_run", "evidence_run", "report_latest", "evidence_latest", "declared_issue_updates"]
	requireAuthorityRead: true
	requireBothChannels: true
	forbidUndeclaredIssueUpdates: true
}) & {
	issueTargets: {}
}

publicationAdmission: close({
	reportsEnabled: true
	evidenceEnabled: true
	issueUpdatesEnabled: len(upstreamCodexPublicationPlan.issueTargets) > 0
	requireOperationalContract: true
	requireFixedTemplate: true
})
