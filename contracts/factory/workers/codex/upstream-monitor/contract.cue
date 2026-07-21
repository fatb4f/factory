package upstreammonitor

import "list"

#NonEmptyString:     string & !=""
#NonEmptyStringList: [...#NonEmptyString] & [_, ...]
#CommitSHA:          string & =~"^[0-9a-f]{40}$"
#GitObjectSHA:       string & =~"^[0-9a-f]{40}$"
#TerminalState:      "terminal_success" | "terminal_abort" | "terminal_deferred" | "coverage_gap"
#ChannelID:          "main" | "latest-alpha-cli"
#ChannelStatus:      "resolved" | "unresolved"
#ImpactDecision:     "none" | "note" | "contract-update" | "blocking-gate"
#Severity:           "none" | "note" | "high" | "critical"
#SurfaceClass:       "protocol" | "adapter" | "storage" | "policy" | "ui" | "docs" | "context-window" | "multi-agent" | "rollout-trace" | "mcp" | "config" | "security" | "release"
#RunArtifactKind:    "report" | "summary" | "evidence"
#IssueUpdatePolicy:  "minimum_impact" | "every_run"
#ObservationID:      #NonEmptyString

#CorrectionLineage: close({
	supersedes_run_id:        #NonEmptyString
	superseded_bundle_path:   #NonEmptyString
	superseded_manifest_path: #NonEmptyString
	reason:                   #NonEmptyString
})

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
	correction?:         #CorrectionLineage
	artifacts:           [_, ...#RunBundleArtifact]
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
	evidence:           [_, ...#NonEmptyString]
})

#ClassifiedObservation: {
	id:             #ObservationID
	reportItemID:   #NonEmptyString
	channel:        #ChannelID
	path:           #NonEmptyString
	surfaceMatches: [_, ...#NonEmptyString]
	observation:    #NonEmptyString
	decision:       #ImpactDecision
	let Decision = decision
	severity: #Severity
	if Decision == "none" {
		severity: "none"
	}
	if Decision == "note" {
		severity: "note"
	}
	if Decision == "contract-update" {
		severity: "high"
	}
	if Decision == "blocking-gate" {
		severity: "critical"
	}
}

#EvidenceBinding: close({
	observationID:  #ObservationID
	reportItemID:   #NonEmptyString
	channel:        #ChannelID
	path:           #NonEmptyString
	surfaceMatches: [_, ...#NonEmptyString]
	observation:    #NonEmptyString
})

#EvidenceClaim: close({
	id:              #NonEmptyString
	text:            #NonEmptyString
	observationRefs: [_, ...#ObservationID]
})

#SurfaceCoverage: close({
	surfaceID:       #NonEmptyString
	channelsScanned: [_, ...#ChannelID]
	observationRefs: [...#ObservationID]
})

#ReportItem: close({
	id:                     #NonEmptyString
	channels:               [_, ...#ChannelID]
	severity:               #Severity
	impactDecision:         #ImpactDecision
	title:                  #NonEmptyString
	summary:                #NonEmptyString
	surfaceMatches:         [_, ...#NonEmptyString]
	evidence:               [_, ...#NonEmptyString]
	evidenceBindings?:      [_, ...#EvidenceBinding]
	claims?:                [_, ...#EvidenceClaim]
	localContractImpact?:   #NonEmptyString
	suggestedLocalTargets?: [...#NonEmptyString]
	trackedIssueRefs?:      [...int]
})

#EvidenceBackedReportItem: #ReportItem & {
	id:               #NonEmptyString
	channels:         [_, ...#ChannelID]
	surfaceMatches:   [_, ...#NonEmptyString]
	evidenceBindings: [_, ...#EvidenceBinding]
	claims:           [_, ...#EvidenceClaim]

	let ItemID = id
	let ItemChannels = channels
	let ItemSurfaces = surfaceMatches

	_bindingChannels: [for binding in evidenceBindings {binding.channel}]
	_channelCoverage: [for channel in ItemChannels {
		list.Contains(_bindingChannels, channel)
	}]
	_channelCoverage: [...true]

	_bindingChannelAdmission: [for binding in evidenceBindings {
		list.Contains(ItemChannels, binding.channel)
	}]
	_bindingChannelAdmission: [...true]

	_bindingSurfaces: [for binding in evidenceBindings for surface in binding.surfaceMatches {surface}]
	_surfaceCoverage: [for surface in ItemSurfaces {
		list.Contains(_bindingSurfaces, surface)
	}]
	_surfaceCoverage: [...true]

	_bindingSurfaceAdmission: [for binding in evidenceBindings for surface in binding.surfaceMatches {
		list.Contains(ItemSurfaces, surface)
	}]
	_bindingSurfaceAdmission: [...true]

	_bindingObservationIDs: [for binding in evidenceBindings {binding.observationID}]
	_bindingItemOwnership: [for binding in evidenceBindings {
		binding.reportItemID == ItemID
	}]
	_bindingItemOwnership: [...true]

	_claimReferencesBound: [for claim in claims for observationRef in claim.observationRefs {
		list.Contains(_bindingObservationIDs, observationRef)
	}]
	_claimReferencesBound: [...true]
}

#IssueTarget: close({
	repo:             #NonEmptyString
	number:           int & >0
	updatePolicy:     #IssueUpdatePolicy
	minimumImpact?:   "note" | "contract-update" | "blocking-gate"
	mutation:         "append_comment"
	dedupeKeyPattern: #NonEmptyString
	terminalStates?:  [_, ...#TerminalState]
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
