package contractsurface

#ImpactSeverity: "critical" | "high" | "note" | "no-local-action"

#ImpactClass: "mcp" |
	"security" |
	"storage" |
	"adapter" |
	"protocol" |
	"rollout-trace" |
	"ui" |
	"multi-agent" |
	"context-window" |
	"config" |
	"policy"

#UpstreamSignalStatus: "admitted" | "unresolved" | "ignored"

#UpstreamEvent: {
	id:           string
	upstreamRepo: "openai/codex"
	kind:         "pull_request" | "branch_or_ref" | "release" | "unknown"
	status:       #UpstreamSignalStatus
	evidence:      [...string]
	refs?:        [...string]
	note?:        string
}

#ImpactItem: {
	event:       #UpstreamEvent
	severity:    #ImpactSeverity
	classes:     [...#ImpactClass]
	impact:      string
	localReason: string
	localTargets?: [...string]
	issueUpdates?: [...#IssueUpdateCandidate]
}

#ImpactReport: {
	apiVersion: "factory.upstream-monitor.codex/v0"
	kind:       "CodexImpactReport"

	metadata: {
		issue:       69
		loop:        "codex-contract-surface"
		generatedBy: "scheduled-chatgpt-task"
		authority:   "cue-owned-report-shape"
	}

	source: {
		upstreamRepo: "openai/codex"
		targetRepo:   "fatb4f/factory"
		entrypoint:   "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
		adapter:      "github_app"
	}

	template: {
		id: "codex-impact-report-fixed-v0"
		sections: [
			"critical",
			"high",
			"notes",
			"noLocalAction",
			"suggestedLocalTargets",
			"issueUpdates",
		]
	}

	impacts: {
		critical:      *([]) | [...#ImpactItem]
		high:          *([]) | [...#ImpactItem]
		notes:         *([]) | [...#ImpactItem]
		noLocalAction: *([]) | [...#ImpactItem]
	}

	suggestedLocalTargets: *([]) | [...string]
	unresolvedEvidence:   *([]) | [...#UpstreamEvent]
}
