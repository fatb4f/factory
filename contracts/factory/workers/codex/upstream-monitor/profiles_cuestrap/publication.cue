package cuestrapprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#IssueTarget: core.#IssueTarget & {
	repo:             "fatb4f/cuestrap"
	updatePolicy:     "every_run"
	mutation:         "append_comment"
	dedupeKeyPattern: "cuestrap-codex-contract-surface/<run_id>"
	terminalStates: [
		"terminal_success",
		"terminal_abort",
		"terminal_deferred",
		"coverage_gap",
	]
}

cuestrapPublicationPlan: close({
	factoryRepository: "fatb4f/factory"
	factory: close({
		bundle: close({
			directoryPattern: "contracts/upstream-monitor/codex/cuestrap-contract-surface/runs/<run_id>/"
			artifacts: close({
				report: close({
					filename:  "report.md"
					mediaType: "text/markdown"
				})
				summary: close({
					filename:  "summary.md"
					mediaType: "text/markdown"
				})
				evidence: close({
					filename:  "evidence.json"
					mediaType: "application/json"
				})
			})
			manifest: close({
				filename:   "manifest.json"
				mediaType:  "application/json"
				apiVersion: "factory.upstream-monitor.run-bundle/v1"
				kind:       "UpstreamMonitorRunBundle"
				profile_id: "cuestrap"
			})
			exportUnit: "directory"
		})
		latestPointer: close({
			path:       "contracts/upstream-monitor/codex/cuestrap-contract-surface/latest.json"
			mediaType:  "application/json"
			apiVersion: "factory.upstream-monitor.latest-run/v1"
			kind:       "LatestUpstreamMonitorRun"
		})
	})
	issueTargets: [string]: #IssueTarget
	issueAudit: close({
		target:        "runLog"
		timing:        "after_terminal_state_determined"
		failurePolicy: "append_with_available_results_and_failure_reason"
		bodyMutation:  "forbidden"
	})
	writeOrder: [
		"factory_bundle_report",
		"factory_bundle_summary",
		"factory_bundle_evidence",
		"factory_bundle_manifest",
		"factory_latest_pointer",
		"declared_issue_updates",
	]
	requireAuthorityRead:              true
	requireCurrentCuestrapContext:     true
	requireBothChannels:               true
	requireRunBundle:                  true
	requireBundleManifestLast:         true
	requireLatestPointerAfterManifest: true
	requireTrackingIssueOpen:          true
	requireIssueCommentEveryRun:       true
	requireIssueCommentDedupe:         true
	forbidIssueBodyMutation:           true
	forbidRunArtifactsOutsideBundle:   true
	forbidMutableLatestArtifactCopies: true
	forbidLegacyWrites:                true
	forbidLegacyPathsPresent:          true
	forbidCuestrapRepositoryArtifacts: true
	forbidCuestrapEvidence:            true
	forbidCuestrapPlumbing:            true
	forbidUndeclaredIssueUpdates:      true
}) & {
	issueTargets: {
		runLog: {
			number: 9
		}
	}
}

cuestrapPublicationAdmission: close({
	factoryRunBundleEnabled:              true
	factoryEvidenceEnabled:               true
	summariesEnabled:                     true
	manifestsEnabled:                     true
	latestPointersEnabled:                true
	legacyLedgersPruned:                   true
	cuestrapRepositoryArtifactsEnabled:   false
	cuestrapEvidenceEnabled:              false
	cuestrapPlumbingEnabled:              false
	issueUpdatesEnabled:                  true
	requireOperationalContract:           true
	requireFixedTemplate:                 true
	requireCompleteFactoryBundle:         true
	requireNoCuestrapRepositoryArtifacts: true
	requireRunLogComment:                 true
})
