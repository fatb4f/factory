package contractsurface

#PublicationMode: "repo-report" | "issue-comment" | "closed-issue-note"

#IssueUpdateCandidate: {
	issue: int
	mode:  #PublicationMode
	target: "active-work" | "umbrella-status" | "closed-issue-archive"
	body: string
}

#RepoReportArtifact: {
	kind:          "markdown-report"
	path:          =~"^contracts/upstream-monitor/codex/contract-surface/reports/[^/]+\\.md$"
	generatedFrom: "upstreamCodexImpactReportTemplate"
	template:      "codex-impact-report-fixed-v0"
	authority:     false
}

#PublicationPlan: {
	apiVersion: "factory.upstream-monitor.codex/v0"
	kind:       "CodexReportPublicationPlan"

	issue: 69
	adapter: "github_app"
	mutation: "declared-output-only"

	report: #RepoReportArtifact

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
		"report artifacts are projections/evidence, not authority",
		"ChatGPT applies the fixed template but does not own semantic admission",
		"GitHub App writes only declared publication targets",
		"unresolved upstream signals remain unresolved evidence until ref/tag/branch proof exists",
	]
}
