package contractsurface

#PublicationMode: "repo-report" | "issue-comment" | "closed-issue-note"

#IssueUpdateCandidate: {
	issue: int
	mode:  #PublicationMode
	target: "active-work" | "umbrella-status" | "closed-issue-archive"
	body: string
}

#RunID: =~"^[0-9]{8}T[0-9]{6}Z$"

#RepoReportArtifact: {
	kind:          "markdown-report"
	path:          =~"^contracts/upstream-monitor/codex/contract-surface/reports/[^/]+\\.md$"
	generatedFrom: "upstreamCodexImpactReportTemplate"
	template:      "codex-impact-report-fixed-v0"
	authority:     false
}

#RunReportArtifact: {
	kind:          "markdown-report"
	path:          =~"^contracts/upstream-monitor/codex/contract-surface/reports/runs/[0-9]{8}T[0-9]{6}Z\\.codex-impact\\.md$"
	generatedFrom: "upstreamCodexImpactReportTemplate"
	template:      "codex-impact-report-fixed-v0"
	authority:     false
	retention:     "durable-run-record"
}

#LatestReportProjection: {
	kind:          "markdown-report"
	path:          "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md"
	generatedFrom: "run-report-artifact"
	template:      "codex-impact-report-fixed-v0"
	authority:     false
	projection:    "latest-run-pointer"
}

#RunEvidenceArtifact: {
	kind:      "json-evidence"
	path:      =~"^contracts/upstream-monitor/codex/contract-surface/evidence/runs/[0-9]{8}T[0-9]{6}Z\\.codex-impact\\.report\\.json$"
	authority: false
	retention: "durable-run-record"
}

#LatestEvidenceProjection: {
	kind:       "json-evidence"
	path:       "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json"
	authority:  false
	projection: "latest-run-pointer"
}

#RunArtifactTarget: {
	pathPattern: string
	pathRegex:   string
	authority:   false
	retention:   "durable-run-record"
}

#LatestProjectionTarget: {
	path:       string
	authority:  false
	projection: "latest-run-pointer"
}

#ReportPublicationTargets: {
	run: #RunArtifactTarget & {
		pathPattern: "contracts/upstream-monitor/codex/contract-surface/reports/runs/<run_id>.codex-impact.md"
		pathRegex:   "^contracts/upstream-monitor/codex/contract-surface/reports/runs/[0-9]{8}T[0-9]{6}Z\\\\.codex-impact\\\\.md$"
	}
	latest: #LatestProjectionTarget & {
		path: "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md"
	}
}

#EvidencePublicationTargets: {
	run: #RunArtifactTarget & {
		pathPattern: "contracts/upstream-monitor/codex/contract-surface/evidence/runs/<run_id>.codex-impact.report.json"
		pathRegex:   "^contracts/upstream-monitor/codex/contract-surface/evidence/runs/[0-9]{8}T[0-9]{6}Z\\\\.codex-impact\\\\.report\\\\.json$"
	}
	latest: #LatestProjectionTarget & {
		path: "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json"
	}
}

#PublicationPlan: {
	apiVersion: "factory.upstream-monitor.codex/v0"
	kind:       "CodexReportPublicationPlan"

	issue: 69
	adapter: "github_app"
	mutation: "declared-output-only"

	report: #ReportPublicationTargets
	evidence: #EvidencePublicationTargets

	issueTargets: {
		"42"?: #IssueUpdateCandidate & {
			issue: 42
			mode:  "issue-comment"
			target: "active-work"
		}
		"45"?: #IssueUpdateCandidate & {
			issue: 45
			mode:  "issue-comment"
			target: "umbrella-status"
		}
		"47"?: #IssueUpdateCandidate & {
			issue: 47
			mode:  "closed-issue-note"
			target: "closed-issue-archive"
		}
		"48"?: #IssueUpdateCandidate & {
			issue: 48
			mode:  "closed-issue-note"
			target: "closed-issue-archive"
		}
	}

	invariants: [
		"run artifacts are durable projections/evidence, not authority",
		"latest artifacts are overwriteable projections of the most recent admitted run",
		"ChatGPT applies the fixed template but does not own semantic admission",
		"GitHub App writes only declared publication targets",
		"unresolved upstream signals remain unresolved evidence until ref/tag/branch proof exists",
	]
}
