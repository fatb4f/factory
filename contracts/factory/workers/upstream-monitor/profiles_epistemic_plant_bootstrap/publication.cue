package epistemicplantprofile

epistemicPlantPublicationPlan: close({
	factoryRepository: "fatb4f/factory"
	bundle: close({
		directoryPattern: "projects/epistemic-plant-bootstrap/upstream-monitor/runs/<run_id>/"
		artifacts: close({
			report: {filename: "report.md", mediaType: "text/markdown"}
			summary: {filename: "summary.md", mediaType: "text/markdown"}
			evidence: {filename: "evidence.json", mediaType: "application/json"}
		})
		manifest: close({
			filename: "manifest.json"
			mediaType: "application/json"
			apiVersion: "factory.upstream-monitor.run-bundle/v2"
			kind: "UpstreamMonitorRunBundle"
			profile_id: "epistemic-plant-bootstrap"
		})
		exportUnit: "directory"
	})
	latestPointer: close({
		path: "projects/epistemic-plant-bootstrap/upstream-monitor/latest.json"
		mediaType: "application/json"
		apiVersion: "factory.upstream-monitor.latest-run/v2"
		kind: "LatestUpstreamMonitorRun"
		recordAuthorityRevision: true
		recordPublicationRevision: true
		publicationRevisionMeaning: "commit that seals manifest.json; never the self-referential latest-pointer commit"
	})
	writeOrder: [
		"bundle_report",
		"bundle_summary",
		"bundle_evidence",
		"bundle_manifest",
		"latest_pointer",
	]
	requireAuthorityRead: true
	requireCurrentSubjectContext: true
	requireRequiredSourcesResolvedOrExplicitlyUnresolved: true
	requireRunBundle: true
	requireBundleManifestLast: true
	requireLatestPointerAfterManifest: true
	requireAuthorityRevisionFromPrePublicationAuthoritySnapshot: true
	requirePublicationRevisionFromManifestSealCommit: true
	forbidSelfReferentialLatestPointerRevision: true
	forbidRunArtifactsOutsideBundle: true
	forbidMutableLatestArtifactCopies: true
	forbidSubjectEvidenceCopyIntoAuthority: true
	forbidCrossRepositoryWrites: true
	forbidUndeclaredIssueUpdates: true
})

epistemicPlantPublicationAdmission: close({
	factoryRunBundleEnabled: true
	evidenceEnabled: true
	summariesEnabled: true
	manifestsEnabled: true
	latestPointersEnabled: true
	issueUpdatesEnabled: false
	requireOperationalContract: true
	requireFixedTemplate: true
	requireCompleteBundle: true
})
