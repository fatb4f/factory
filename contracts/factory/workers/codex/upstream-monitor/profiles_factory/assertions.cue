package factoryprofile

import core "github.com/fatb4f/factory/contracts/factory/workers/codex/upstream-monitor:upstreammonitor"

forbiddenAttractors: [
	"ChatGPT output treated as authority",
	"GitHub adapter output treated as authority",
	"openai/codex treated as authority",
	"latest-alpha-cli evidence assigned to main",
	"main evidence assigned to latest-alpha-cli",
	"unresolved ref populated from inference",
	"untyped evidence strings used as sole report proof",
	"non-empty typed list with an unconstrained first element",
	"duplicate observation, report-item, binding, or claim identity",
	"observation decision or severity diverges from its report-item bucket",
	"evidence binding not referenced by any typed claim",
	"declared channel without a channel-bound evidence observation",
	"declared surface without a surface-bound evidence observation",
	"claim references evidence outside its report item",
	"surface-matched observation omitted from the classification ledger",
	"surface coverage omitted for a declared catalogue entry",
	"Markdown claim absent from evidence.json",
	"run artifacts split across report and evidence directories",
	"run artifact written outside its runs/<run_id>/ bundle",
	"bundle manifest published before required artifacts",
	"mutable latest report or evidence copy",
	"sealed run bundle mutated in place",
	"correction published without supersession lineage",
	"legacy report or evidence path used for a new write",
	"issue update without publication target",
	"claimant-supplied admission boolean",
]

validationAssertions: close({
	acceptedSignalExact:             true
	mainRefExact:                    true
	alphaRefExact:                   true
	channelsDistinct:                true
	upstreamEvidenceOnly:            true
	chatgptIsActuatorNotAuthority:   true
	typedEvidenceBindingsRequired:   true
	typedNonEmptyListsExact:         true
	observationIDsUnique:            true
	reportItemIDsUnique:             true
	bindingObservationIDsUnique:     true
	claimIDsUnique:                  true
	bindingDecisionSeverityAligned:  true
	everyBindingReferencedByAClaim:  true
	declaredChannelEvidenceCovered:  true
	declaredSurfaceEvidenceCovered:  true
	claimsReferenceBoundEvidence:    true
	observationLedgerRequired:       true
	observationLedgerFullyReported:  true
	surfaceCoverageLedgerRequired:   true
	allCatalogueSurfacesScanned:     true
	severityBucketsExact:            true
	markdownProjectionOnly:          true
	correctionsUseSupersedingRuns:   true
	sealedRunBundlesImmutable:       true
	runArtifactsCoLocated:           true
	bundleExportUnitIsDirectory:     true
	bundleManifestSealsArtifacts:    true
	latestIsPointerOnly:             true
	legacyPathsReadOnly:             true
	undeclaredIssueUpdatesForbidden: true
	unresolvedEvidencePreserved:     true
	workflowClosed:                  true
})

negativeFixtures: {
	collapseChannels:         close({main: "latest-alpha-cli", alpha: "latest-alpha-cli"})
	promoteUpstreamAuthority: close({authority: "openai/codex"})
	inferUnresolvedHead:      close({status: "unresolved", inferred_head: core.#CommitSHA})
	untypedEvidenceOnly:      close({evidence: [core.#NonEmptyString], evidenceBindingsPresent: false})
	partiallyTypedList:       close({firstElementTyped: false, remainingElementsTyped: true})
	duplicateObservationID:   close({observationIDs: [core.#ObservationID, core.#ObservationID], unique: false})
	decisionSeverityDrift:    close({observationDecision: "note", reportDecision: "contract-update", aligned: false})
	unclaimedBinding:         close({observationID: core.#ObservationID, referencedByClaim: false})
	missingChannelBinding:    close({channels: ["main", "latest-alpha-cli"], evidenceChannels: ["main"]})
	missingSurfaceBinding:    close({surfaces: ["mcp-tools", "configuration"], evidenceSurfaces: ["mcp-tools"]})
	unboundClaim:             close({claimObservationRef: core.#ObservationID, bound: false})
	unreportedObservation:    close({observationID: core.#ObservationID, reportItemID: core.#NonEmptyString, boundToReport: false})
	unscannedSurface:         close({surfaceID: core.#NonEmptyString, coverageDeclared: false})
	independentMarkdownClaim: close({presentInEvidenceJSON: false, rendered: true})
	scatteredRunArtifacts:    close({reportDirectory: core.#NonEmptyString, evidenceDirectory: core.#NonEmptyString, sameDirectory: false})
	unbundledRunArtifact:     close({path: string & !~"^contracts/upstream-monitor/codex/contract-surface/runs/[^/]+/"})
	manifestBeforeArtifacts:  close({manifestWritten: true, requiredArtifactsComplete: false})
	mutableLatestCopy:        close({path: string & =~"^contracts/upstream-monitor/codex/contract-surface/(reports|evidence)/latest"})
	sealedRunMutation:        close({sealed: true, mutation: true})
	correctionWithoutLineage: close({correction: true, supersedes_run_id: ""})
	legacyWrite:              close({path: "contracts/upstream-monitor/codex/contract-surface/reports/latest.codex-impact.md" | "contracts/upstream-monitor/codex/contract-surface/evidence/latest.codex-impact.report.json", write: true})
	undeclaredIssueMutation:  close({target: int & >0, declared: false})
}

validationPlan: close({
	commands: [
		"cue fmt --check contract.cue profiles_factory/*.cue",
		"cue vet -c=false ./...",
		"cue export ./profiles_factory -e publicContract --out json",
	]
	adapterLimitation: "The GitHub App actuator cannot execute these commands; repository CI or a checked local environment performs executable validation."
})
