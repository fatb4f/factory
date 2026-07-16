package cuestrapprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#IssueTarget: core.#IssueTarget & {
	repo: "fatb4f/factory"
}

cuestrapPublicationPlan: close({
	factoryRepository: "fatb4f/factory"
	factory: close({
		report: close({
			runPattern: "contracts/upstream-monitor/codex/cuestrap-contract-surface/reports/runs/<run_id>.codex-impact.md"
			latestPath: "contracts/upstream-monitor/codex/cuestrap-contract-surface/reports/latest.codex-impact.md"
		})
		evidence: close({
			runPattern: "contracts/upstream-monitor/codex/cuestrap-contract-surface/evidence/runs/<run_id>.codex-impact.report.json"
			latestPath: "contracts/upstream-monitor/codex/cuestrap-contract-surface/evidence/latest.codex-impact.report.json"
		})
	})
	mirror: close({
		repository: "fatb4f/cuestrap"
		branch:     "main"
		report: close({
			runPattern: "reports/upstream-monitor/codex/runs/<run_id>.codex-impact.md"
			latestPath: "reports/upstream-monitor/codex/latest.codex-impact.md"
		})
		contentPolicy: "byte_equivalent_to_factory_report"
		evidenceAllowed: false
		plumbingAllowed: false
	})
	issueTargets: [string]: #IssueTarget
	writeOrder: [
		"factory_report_run",
		"factory_evidence_run",
		"factory_report_latest",
		"factory_evidence_latest",
		"cuestrap_report_run_copy",
		"cuestrap_report_latest_copy",
		"declared_issue_updates",
	]
	requireAuthorityRead:          true
	requireCurrentCuestrapContext: true
	requireBothChannels:           true
	requireMirrorContentEquality:  true
	forbidCuestrapEvidence:        true
	forbidCuestrapPlumbing:        true
	forbidUndeclaredIssueUpdates:  true
}) & {
	issueTargets: {}
}

cuestrapPublicationAdmission: close({
	factoryReportsEnabled: true
	factoryEvidenceEnabled: true
	cuestrapReportMirrorEnabled: true
	cuestrapEvidenceEnabled: false
	cuestrapPlumbingEnabled: false
	issueUpdatesEnabled: false
	requireOperationalContract: true
	requireFixedTemplate: true
	requireMirrorDigestMatch: true
})
