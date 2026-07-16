package upstreammonitor

#NonEmptyString: string & !=""
#CommitSHA: string & =~"^[0-9a-f]{40}$"
#TerminalState: "terminal_success" | "terminal_abort" | "terminal_deferred" | "coverage_gap"
#ChannelID: "main" | "latest-alpha-cli"
#ChannelStatus: "resolved" | "unresolved"

#AcceptedSignal: close({
	signal_id:  "loop_bootstrap_request"
	target_repo: "fatb4f/factory"
	entrypoint: "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
	adapter:    "github_app"
})

#Channel: close({
	id:   #ChannelID
	repo: "openai/codex"
	ref:  #ChannelID
	role: "upstream_evidence_only"
})

#ChannelObservation: close({
	channel: #ChannelID
	status:  #ChannelStatus
	head_commit?:      #CommitSHA
	workspace_version?: #NonEmptyString
	evidence: [_, ...#NonEmptyString]
})

acceptedSignal: #AcceptedSignal & {
	signal_id:  "loop_bootstrap_request"
	target_repo: "fatb4f/factory"
	entrypoint: "contracts/upstream-monitor/codex/contract-surface/AGENTS.md"
	adapter:    "github_app"
}

authorityModel: close({
	authority: [
		"contracts/factory/workers/codex/upstream-monitor/*.cue",
		"contracts/factory/workers/codex/upstream-monitor/AGENTS.md",
		"contracts/upstream-monitor/**/AGENTS.md",
		"contracts/upstream-monitor/codex/contract-surface/output/report-template.md",
	]
	evidenceOnly: [
		"openai/codex",
		"GitHub adapter responses",
		"ChatGPT observations",
		"generated reports",
		"generated evidence",
	]
})

channels: close({
	main: #Channel & {
		id:  "main"
		ref: "main"
	}
	"latest-alpha-cli": #Channel & {
		id:  "latest-alpha-cli"
		ref: "latest-alpha-cli"
	}
})

chatgptActuator: close({
	kind:    "chatgpt_scheduled_actuator"
	adapter: "github_app"
	readsAuthorityBeforeEvidence: true
	semanticClassificationOwner:  "chatgpt_constrained_by_cue"
	mayAcquireUpstreamEvidence:    true
	mayRenderAdmittedReports:      true
	mayWriteAdmittedEvidence:      true
	mayUpdateDeclaredIssues:       true
	mustFailClosed:                true
})

workflow: close({
	initial: "authority_read"
	states: [
		"authority_read",
		"input_admission",
		"main_acquisition",
		"alpha_acquisition",
		"semantic_classification",
		"report_render",
		"publication_admission",
		"publication",
	]
	transitions: [
		{from: "authority_read", to: "input_admission"},
		{from: "input_admission", to: "main_acquisition"},
		{from: "main_acquisition", to: "alpha_acquisition"},
		{from: "alpha_acquisition", to: "semantic_classification"},
		{from: "semantic_classification", to: "report_render"},
		{from: "report_render", to: "publication_admission"},
		{from: "publication_admission", to: "publication"},
		{from: "publication", to: "terminal_success"},
	]
	failureStates: ["terminal_abort", "terminal_deferred", "coverage_gap"]
	terminal:       "terminal_success"
})

operational: true
