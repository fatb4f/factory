package upstreammonitor

upstreamMonitorHandoff: close({
	schema: "factory.upstream-monitor-handoff.v1"
	issue:  "#73"
	state:  "S7 UpstreamMonitorAttached"
	repository: "fatb4f/factory"
	branch: "main"
	entrypoint: "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
	futureIssueSurface: "fatb4f/factory"
	sourceIssueSurface: "fatb4f/contract.cuemod#66-#73 are provenance only"
	scheduledReviewOutput: "contracts/upstream-monitor/codex/contract-surface"
})
