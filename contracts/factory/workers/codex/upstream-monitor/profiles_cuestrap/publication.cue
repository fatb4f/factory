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
		legacyReadOnly: close({
			reportLatestPath:   "contracts/upstream-monitor/codex/cuestrap-contract-surface/reports/latest.codex-impact.md"
			evidenceLatestPath: "contracts/upstream-monitor/codex/cuestrap-contract-surface/evidence/latest.codex-impact.report.json"
		})
	})
	mirror: close({
		repository: "fatb4f/cuestrap"
		branch:     "main"
		bundle: close({
			directoryPattern: "reports/upstream-monitor/codex/runs/<run_id>/"
			artifacts: close({
				report: close({
					filename:  "report.md"
					mediaType: "text/markdown"
				})
				summary: close({
					filename:  "summary.md"
					mediaType: "text/markdown"
				})
			})
			manifest: close({
				filename:   "manifest.json"
				mediaType:  "application/json"
				apiVersion: "factory.upstream-monitor.run-bundle/v1"
				kind:       "UpstreamMonitorRunBundleProjection"
				profile_id: "cuestrap"
				projection: "report_summary_only"
			})
			exportUnit: "directory"
		})
		latestPointer: close({
			path:       "reports/upstream-monitor/codex/latest.json"
			mediaType:  "application/json"
			apiVersion: "factory.upstream-monitor.latest-run/v1"
			kind:       "LatestUpstreamMonitorRun"
		})
		legacyReadOnly: close({
			reportLatestPath: "reports/upstream-monitor/codex/latest.codex-impact.md"
		})
		contentPolicy: close({
			report:   "byte_equivalent_to_factory_report"
			summary:  "byte_equivalent_to_factory_summary"
			manifest: "report_projection_inventory_only"
		})
		evidenceAllowed: false
		plumbingAllowed: false
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
		"cuestrap_bundle_report_copy",
		"cuestrap_bundle_summary_copy",
		"cuestrap_bundle_manifest",
		"cuestrap_latest_pointer",
		"declared_issue_updates",
	]
	requireAuthorityRead:               true
	requireCurrentCuestrapContext:      true
	requireBothChannels:                true
	requireRunBundle:                   true
	requireBundleManifestLast:          true
	requireLatestPointerAfterManifest:  true
	requireMirrorContentEquality:       true
	requireMirrorManifestSourceBinding: true
	requireTrackingIssueOpen:           true
	requireIssueCommentEveryRun:        true
	requireIssueCommentDedupe:          true
	forbidIssueBodyMutation:            true
	forbidRunArtifactsOutsideBundle:    true
	forbidMutableLatestArtifactCopies:  true
	forbidLegacyWrites:                 true
	forbidCuestrapEvidence:             true
	forbidCuestrapPlumbing:             true
	forbidUndeclaredIssueUpdates:       true
}) & {
	issueTargets: {
		runLog: {
			number: 9
		}
	}
}

cuestrapPublicationAdmission: close({
	factoryRunBundleEnabled:      true
	cuestrapReportBundleEnabled:  true
	factoryEvidenceEnabled:       true
	summariesEnabled:             true
	manifestsEnabled:             true
	latestPointersEnabled:        true
	cuestrapEvidenceEnabled:      false
	cuestrapPlumbingEnabled:      false
	issueUpdatesEnabled:          true
	requireOperationalContract:   true
	requireFixedTemplate:         true
	requireCompleteFactoryBundle: true
	requireMirrorDigestMatch:     true
	requireRunLogComment:         true
})