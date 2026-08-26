package factoryprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

#IssueTarget: core.#IssueTarget & {
	repo: "fatb4f/factory"
}

upstreamCodexPublicationPlan: close({
	repository: "fatb4f/factory"
	bundle: close({
		directoryPattern: "projects/factory/upstream-monitor/runs/<run_id>/"
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
			profile_id: "factory"
		})
		exportUnit: "directory"
	})
	latestPointer: close({
		path:       "projects/factory/upstream-monitor/latest.json"
		mediaType:  "application/json"
		apiVersion: "factory.upstream-monitor.latest-run/v1"
		kind:       "LatestUpstreamMonitorRun"
	})
	legacyReadOnly: close({
		reportLatestPath:   "projects/factory/upstream-monitor/legacy-reports/latest.codex-impact.md"
		evidenceLatestPath: "projects/factory/upstream-monitor/legacy-evidence/latest.codex-impact.report.json"
	})
	corrections: close({
		sealedBundlesImmutable:        true
		requireSupersedingRun:         true
		requireCorrectionLineage:      true
		manifestCarriesLineage:        true
		latestMayAdvanceOnlyAfterSeal: true
	})
	issueTargets: [string]: #IssueTarget
	writeOrder: [
		"bundle_report",
		"bundle_summary",
		"bundle_evidence",
		"bundle_manifest",
		"latest_pointer",
		"declared_issue_updates",
	]
	requireAuthorityRead:              true
	requireBothChannels:               true
	requireRunBundle:                  true
	requireBundleManifestLast:         true
	requireLatestPointerAfterManifest: true
	forbidRunArtifactsOutsideBundle:   true
	forbidMutableLatestArtifactCopies: true
	forbidLegacyWrites:                true
	forbidUndeclaredIssueUpdates:      true
	forbidSealedRunMutation:           true
}) & {
	issueTargets: {}
}

publicationAdmission: close({
	reportsEnabled:              true
	summariesEnabled:            true
	evidenceEnabled:             true
	manifestsEnabled:            true
	latestPointersEnabled:       true
	issueUpdatesEnabled:         false
	requireOperationalContract:  true
	requireFixedTemplate:        true
	requireCompleteRunBundle:    true
	requireTypedEvidenceModel:   true
	requireProjectionOnlyRender: true
})
