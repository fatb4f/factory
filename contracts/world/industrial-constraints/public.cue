package industrialconstraints

#Digest: string & =~"^sha256:[0-9a-f]{64}$"

#PublishedClaim: close({
	claim:           #RecordRef & {kind: "claim" | "constraint-claim"}
	assessment:      #RecordRef & {kind: "assessment"}
	assessmentState: "supported"
})

#PublicationAdmission:
	close({
		decision:     "admit"
		claims:       [...#PublishedClaim]
		coverageGaps: [...#CoverageGap]
	}) |
	close({
		decision:     "reject"
		claims:       []
		reasons:      [...string] & [_, ...]
		coverageGaps: [...#CoverageGap]
	})

#PublicReport: close({
	runID:                  string
	materialStateChanges:   [...#RecordRef]
	emergingConstraints:    [...#RecordRef]
	bindingConstraints:     [...#RecordRef]
	relievingConstraints:   [...#RecordRef]
	resolvedConstraints:    [...#RecordRef]
	institutionalResponses: [...#RecordRef]
	fundingProcurement:     [...#RecordRef]
	coverageGaps:           [...#CoverageGap]
})

#RunManifest: close({
	runID:            string
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
	publication: #PublicationAdmission
})

#RunBundle: close({
	manifest: #RunManifest
	report:   #PublicReport & {runID: manifest.runID}
	summary:  string
	evidence: [...#Record]
})

publicSurface: close({
	sections: [
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
