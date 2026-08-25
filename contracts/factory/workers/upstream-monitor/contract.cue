package upstreammonitor

#NonEmptyString: string & != ""
#CommitSHA: string & =~ "^[0-9a-f]{40}$"
#GitObjectSHA: string & =~ "^[0-9a-f]{40}$"
#TerminalState: "terminal_success" | "terminal_abort" | "terminal_deferred" | "coverage_gap"
#QualificationState: "observation_only" | "executable_validated" | "executable_failed"
#ImpactDecision: "none" | "note" | "contract-update" | "blocking-gate"
#Severity: "none" | "note" | "high" | "critical"
#SourceRole: "upstream_evidence_only" | "pinned_external_semantics"
#ChannelMode: "active-baseline" | "forecast" | "release-watch" | "pinned-authority"
#ChannelStatus: "resolved" | "unresolved"
#ObservationKind: "source" | "schema" | "projection" | "runtime" | "rollout" | "upstream-test" | "probe" | "dependency" | "context" | "analyzer" | "telemetry" | "semantic-convention" | "transport" | "acquisition" | "external-observation"
#GraphEdgeKind: "depends-on" | "projects-to" | "observed-by" | "validated-by" | "consumed-by"
#RunArtifactKind: "report" | "summary" | "evidence"
#DispatcherTaskID: "projects.ctrl.upstream-monitor" | "projects.epistemic-plant-bootstrap.upstream-monitor"

#DispatcherContext: close({
	task_id: #DispatcherTaskID
	occurrence_id: string & =~ "^projects\\.(ctrl|epistemic-plant-bootstrap)\\.upstream-monitor/[0-9]{4}-[0-9]{2}-[0-9]{2}$"
	attempt_id: string & =~ "^projects\\.(ctrl|epistemic-plant-bootstrap)\\.upstream-monitor/[0-9]{4}-[0-9]{2}-[0-9]{2}/attempt-[1-9][0-9]*$"
	due_plan_digest: string & =~ "^[0-9a-f]{64}$"
})

#UpstreamChannel: close({
	id: #NonEmptyString
	ref: #NonEmptyString
	mode: #ChannelMode
	required: bool
})

#UpstreamSource: close({
	id: #NonEmptyString
	repository: #NonEmptyString
	role: #SourceRole
	channels: [string]: #UpstreamChannel
})

#SourceObservation: close({
	source: #NonEmptyString
	channel: #NonEmptyString
	status: #ChannelStatus
	head_commit?: #CommitSHA
	version?: #NonEmptyString
	evidence: [...#NonEmptyString] & [_, ...]
})

#GraphNode: close({
	id: #NonEmptyString
	domain: #NonEmptyString
	kind: #NonEmptyString
	upstreamPaths: [...#NonEmptyString]
	localConsumers: [...#NonEmptyString]
})

#GraphEdge: close({
	id: #NonEmptyString
	from: #NonEmptyString
	to: #NonEmptyString
	kind: #GraphEdgeKind
	rationale: #NonEmptyString
})

#TestBinding: close({
	id: #NonEmptyString
	node: #NonEmptyString
	upstreamTests: [...#NonEmptyString] & [_, ...]
	invocation?: #NonEmptyString
})

#ProbeBinding: close({
	id: #NonEmptyString
	node: #NonEmptyString
	probe: #NonEmptyString
	observations: [...#NonEmptyString] & [_, ...]
	normalization: [...#NonEmptyString]
})

#ClassifiedObservation: close({
	id: #NonEmptyString
	reportItemID: #NonEmptyString
	source: #NonEmptyString
	channel: #NonEmptyString
	kind: #ObservationKind
	path: #NonEmptyString
	nodeMatches: [...#NonEmptyString] & [_, ...]
	observation: #NonEmptyString
	decision: #ImpactDecision
	severity: #Severity
})

#EvidenceClaim: close({
	id: #NonEmptyString
	text: #NonEmptyString
	observationRefs: [...#NonEmptyString] & [_, ...]
})

#ReportItem: close({
	id: #NonEmptyString
	title: #NonEmptyString
	decision: #ImpactDecision
	severity: #Severity
	sources: [...#NonEmptyString] & [_, ...]
	nodes: [...#NonEmptyString] & [_, ...]
	summary: #NonEmptyString
	localContractImpact?: #NonEmptyString
	observations: [...#ClassifiedObservation] & [_, ...]
	claims: [...#EvidenceClaim] & [_, ...]
})

#RunBundleArtifact: close({
	kind: #RunArtifactKind
	filename: #NonEmptyString
	mediaType: #NonEmptyString
	gitBlobSHA: #GitObjectSHA
})

#RunBundleManifest: close({
	apiVersion: "factory.upstream-monitor.run-bundle/v2"
	kind: "UpstreamMonitorRunBundle"
	run_id: #NonEmptyString
	profile_id: #NonEmptyString
	terminal_state: #TerminalState
	dispatcher?: #DispatcherContext
	export_unit: "directory"
	artifacts: [...#RunBundleArtifact] & [_, ...]
})

#LatestRunPointer: close({
	apiVersion: "factory.upstream-monitor.latest-run/v2"
	kind: "LatestUpstreamMonitorRun"
	run_id: #NonEmptyString
	profile_id: #NonEmptyString
	bundle_path: #NonEmptyString
	manifest_path: #NonEmptyString
	authority_revision?: #CommitSHA
	publication_revision?: #CommitSHA
})

ChatGPTActuator: close({
	kind: "chatgpt_upstream_monitor_actuator"
	adapter: "github_app"
	readsAuthorityBeforeEvidence: true
	semanticClassificationOwner: "chatgpt_constrained_by_cue"
	mayAcquireUpstreamEvidence: true
	mayRenderAdmittedReports: true
	mayWriteAdmittedEvidence: true
	mustFailClosed: true
})
