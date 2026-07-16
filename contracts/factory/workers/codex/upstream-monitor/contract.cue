package upstreammonitor

#NonEmptyString: string & !=""
#NonEmptyStringList: [...#NonEmptyString] & [_, ...]
#CommitSHA:         string & =~"^[0-9a-f]{40}$"
#GitObjectSHA:      string & =~"^[0-9a-f]{40}$"
#TerminalState:     "terminal_success" | "terminal_abort" | "terminal_deferred" | "coverage_gap"
#ChannelID:         "main" | "latest-alpha-cli"
#ChannelStatus:     "resolved" | "unresolved"
#ImpactDecision:    "none" | "note" | "contract-update" | "blocking-gate"
#Severity:          "none" | "note" | "high" | "critical"
#SurfaceClass:      "protocol" | "adapter" | "storage" | "policy" | "ui" | "docs" | "context-window" | "multi-agent" | "rollout-trace" | "mcp" | "config" | "security" | "release"
#RunArtifactKind:   "report" | "summary" | "evidence"
#IssueUpdatePolicy: "minimum_impact" | "every_run"

#RunBundleArtifact: close({
	kind:       #RunArtifactKind
	filename:   #NonEmptyString
	mediaType:  #NonEmptyString
	gitBlobSHA: #GitObjectSHA
})

#RunBundleManifest: close({
	apiVersion:          "factory.upstream-monitor.run-bundle/v1"
	kind:                "UpstreamMonitorRunBundle" | "UpstreamMonitorRunBundleProjection"
	run_id:              #NonEmptyString
	profile_id:          #NonEmptyString
	terminal_state:      #TerminalState
	export_unit:         "directory"
	source_bundle_path?: #NonEmptyString
	artifacts: [_, ...#RunBundleArtifact]
})

#LatestRunPointer: close({
	apiVersion:    "factory.upstream-monitor.latest-run/v1"
	kind:          "LatestUpstreamMonitorRun"
	run_id:        #NonEmptyString
	profile_id:    #NonEmptyString
	bundle_path:   #NonEmptyString
	manifest_path: #NonEmptyString
})

#Channel: close({
	id:   #ChannelID
	repo: "openai/codex"
	ref:  #ChannelID
	role: "upstream_evidence_only"
})

#ChannelObservation: close({
	channel:            #ChannelID
	status:             #ChannelStatus
	head_commit?:       #CommitSHA
	workspace_version?: #NonEmptyString
	evidence: [_, ...#NonEmptyString]
})

#ReportItem: close({
	id: #NonEmptyString
	channels: [_, ...#ChannelID]
	severity:       #Severity
	impactDecision: #ImpactDecision
	title:          #NonEmptyString
	summary:        #NonEmptyString
	surfaceMatches: [_, ...#NonEmptyString]
	evidence: [_, ...#NonEmptyString]
	localContractImpact?: #NonEmptyString
	suggestedLocalTargets?: [...#NonEmptyString]
	trackedIssueRefs?: [...int]
})

#IssueTarget: close({
	repo:             #NonEmptyString
	number:           int & >0
	updatePolicy:     #IssueUpdatePolicy
	minimumImpact?:   "note" | "contract-update" | "blocking-gate"
	mutation:         "append_comment"
	dedupeKeyPattern: #NonEmptyString
	terminalStates?: [_, ...#TerminalState]
})

Channels: close({
	main: #Channel & {
		id:  "main"
		ref: "main"
	}
	"latest-alpha-cli": #Channel & {
		id:  "latest-alpha-cli"
		ref: "latest-alpha-cli"
	}
})

ChatGPTActuator: close({
	kind:                         "chatgpt_scheduled_actuator"
	adapter:                      "github_app"
	readsAuthorityBeforeEvidence: true
	semanticClassificationOwner:  "chatgpt_constrained_by_cue"
	mayAcquireUpstreamEvidence:   true
	mayRenderAdmittedReports:     true
	mayWriteAdmittedEvidence:     true
	mayUpdateDeclaredIssues:      true
	mustFailClosed:               true
})
