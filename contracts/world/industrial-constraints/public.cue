package industrialconstraints

#Digest: string & =~"^sha256:[0-9a-f]{64}$"

#EventObservationRef: close({
	kind: "event-observation"
	id:   #RecordID
})

#PublishedClaim: close({
	claim:           #RecordRef & {kind: "claim" | "constraint-claim"}
	assessment:      #RecordRef & {kind: "assessment"}
	assessmentState: "supported"
})

#EventWatchPublicationAdmission:
	close({
		phase:        "event-watch"
		decision:     "admit"
		events:       [...#EventObservationRef]
		coverageGaps: [...#CoverageGap]
	}) |
	close({
		phase:        "event-watch"
		decision:     "reject"
		events:       []
		reasons:      [...string] & [_, ...]
		coverageGaps: [...#CoverageGap]
	})

#RelationalPublicationAdmission:
	close({
		phase:        "relational-pipeline"
		decision:     "admit"
		claims:       [...#PublishedClaim]
		coverageGaps: [...#CoverageGap]
	}) |
	close({
		phase:        "relational-pipeline"
		decision:     "reject"
		claims:       []
		reasons:      [...string] & [_, ...]
		coverageGaps: [...#CoverageGap]
	})

#PublicationAdmission: #EventWatchPublicationAdmission | #RelationalPublicationAdmission

#EventWatchReport: close({
	runID:                       string
	phase:                       "event-watch"
	observedEvents:               [...#EventObservationRef]
	infrastructureCapacitySignals: [...#EventObservationRef]
	institutionalResponses:       [...#EventObservationRef]
	fundingProcurementSignals:    [...#EventObservationRef]
	coverageGaps:                 [...#CoverageGap]
	constraintClaims:             []
})

#RelationalPublicReport: close({
	runID:                  string
	phase:                  "relational-pipeline"
	materialStateChanges:   [...#RecordRef]
	emergingConstraints:    [...#RecordRef]
	bindingConstraints:     [...#RecordRef]
	relievingConstraints:   [...#RecordRef]
	resolvedConstraints:    [...#RecordRef]
	institutionalResponses: [...#RecordRef]
	fundingProcurement:     [...#RecordRef]
	coverageGaps:           [...#CoverageGap]
})

#PublicReport: #EventWatchReport | #RelationalPublicReport

#EventWatchRunManifest: close({
	runID:            string
	phase:            "event-watch"
	generatedAt:      #Timestamp
	contractPath:     "contracts/world/industrial-constraints/contract.cue"
	contractRevision: string
	immutable:        true
	artifacts: close({
		report:   "report.md"
		summary:  "summary.md"
		evidence: "evidence.json"
	})
	digests: close({
		report:   #Digest
		summary:  #Digest
		evidence: #Digest
	})
	publication: #EventWatchPublicationAdmission
})

#RelationalRunManifest: close({
	runID:            string
	phase:            "relational-pipeline"
	generatedAt:      #Timestamp
	contractPath:     "contracts/world/industrial-constraints/contract.cue"
	contractRevision: string
	immutable:        true
	artifacts: close({
		report:   "report.md"
		summary:  "summary.md"
		evidence: "evidence.json"
		state?:   "state.parquet"
	})
	digests: close({
		report:   #Digest
		summary:  #Digest
		evidence: #Digest
		state?:   #Digest
	})
	publication: #RelationalPublicationAdmission
})

#RunManifest: #EventWatchRunManifest | #RelationalRunManifest
#EventWatchEvidenceRecord: #Document | #EventObservation

#EventWatchRunBundle: close({
	manifest: #EventWatchRunManifest
	report:   #EventWatchReport & {runID: manifest.runID}
	summary:  string
	evidence: [...#EventWatchEvidenceRecord]
})

#RelationalRunBundle: close({
	manifest: #RelationalRunManifest
	report:   #RelationalPublicReport & {runID: manifest.runID}
	summary:  string
	evidence: [...#Record]
})

#RunBundle: #EventWatchRunBundle | #RelationalRunBundle

publicSurface: close({
	currentPhase: "event-watch"
	eventWatchSections: [
		"observed-events",
		"infrastructure-capacity-signals",
		"institutional-responses",
		"funding-procurement-signals",
		"evidence-provenance",
		"coverage-gaps",
	]
	pipelineSections: [
		"material-state-changes",
		"emerging-constraints",
		"binding-constraints",
		"relieving-constraints",
		"resolved-constraints",
		"institutional-responses",
		"funding-procurement-signals",
		"coverage-gaps",
	]
	bundle: close({
		report:   "report.md"
		summary:  "summary.md"
		evidence: "evidence.json"
		state?:   "state.parquet"
		manifest: "manifest.json"
	})
})
