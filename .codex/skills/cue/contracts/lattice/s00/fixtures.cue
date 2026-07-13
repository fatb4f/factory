package s00

import "list"

// Raw adversarial inputs remain separate from their explicit target schemas.
// Validation commands conjoin only the selected fixture with its target.
negativeFixtures: close({
	mutableRevision: {
		target:           "#SourceIdentity"
		targetedMutation: "revision"
		value: {
			repository:   "https://github.com/fatb4f/lattice"
			revision:     "main"
			retrieval:    "git-blob-at-commit"
			movingTarget: false
		}
	}
	movingTargetFlag: {
		target:           "#SourceIdentity"
		targetedMutation: "movingTarget"
		value: {
			repository:   "https://github.com/fatb4f/lattice"
			revision:     source.revision
			retrieval:    "git-blob-at-commit"
			movingTarget: true
		}
	}
	copiedKernelClaim: {
		target:           "#KernelManifest"
		targetedMutation: "status"
		value: {
			id:                         kernelManifest.id
			source:                     kernelManifest.source
			sourcePath:                 kernelManifest.sourcePath
			sourceBlob:                 kernelManifest.sourceBlob
			sourceContentSHA256:        kernelManifest.sourceContentSHA256
			localPath:                  kernelManifest.localPath
			localContentSHA256:         kernelManifest.localContentSHA256
			sourceExportedDeclarations: kernelManifest.sourceExportedDeclarations
			localExportedDeclarations:  kernelManifest.localExportedDeclarations
			exportMapping:              kernelManifest.exportMapping
			divergences:                kernelManifest.divergences
			patternDependencies:        kernelManifest.patternDependencies
			conceptDependencies:        kernelManifest.conceptDependencies
			status:                     "admitted"
		}
	}
	sourceSelectorAfterDot: {
		target:           "#SourceCueSelectorExpr"
		targetedMutation: "definition-marker-after-dot"
		value:            "foo.#Bar"
	}
	unknownPatternField: {
		target:           "#PatternEntry"
		targetedMutation: "unknown-field"
		value: {
			id:             "attributes", path: "patterns/attributes.cue"
			blob:           "274a95c29c03a74f6c6d6e3de6c2d4ee02026a3d"
			contentSHA256:  "28a96a79bbe1a5383001e538ce0e56d22f345bc5929da35ffbadef9278b233b2"
			classification: "application-pattern", status: "provisional"
			admitted:       true
		}
	}
	claimedAdmission: {
		target:           "#QuarantineProjection"
		targetedMutation: "admissionEligible"
		value: {
			patternStatus:  "provisional"
			kernelStatus:   "provisional"
			sourceRevision: source.revision
			requiredPrerequisiteIDs: []
			prerequisiteAdmissions: {}
			patternsAvailable:     true
			kernelAvailable:       true
			prerequisitesAdmitted: true
			downstreamEligible:    false
			admissionEligible:     true
			noWideningEligible:    false
		}
	}
})

requiredNegativeFixtureIDs: [
	"claimed-admission",
	"copied-kernel-claim",
	"moving-target-flag",
	"mutable-revision",
	"source-selector-after-dot",
	"unknown-pattern-field",
]
negativeFixtureEvaluations: close({[ID=string]: #NegativeFixtureEvaluation & {
	fixtureID: ID
}}) & {}
observedNegativeFixtureIDs: list.SortStrings([for id, _ in negativeFixtureEvaluations {id}])
negativeFixtureEvaluationComplete: observedNegativeFixtureIDs == requiredNegativeFixtureIDs &&
	len(negativeFixtureEvaluations) == len(requiredNegativeFixtureIDs) &&
	!list.Contains([for _, evaluation in negativeFixtureEvaluations {evaluation.satisfied}], false)

compatibilityFixtures: close({
	pinnedSourceIdentity:      source.revision == "4148dc1a2d1adfa0782e93e89ea402ce41c56d35"
	localCopyIsDivergent:      kernelManifest.sourceContentSHA256 != kernelManifest.localContentSHA256
	metadataIsNotProof:        patternInventory.metadata.schema.semanticProof == false
	surfacesRemainAvailable:   quarantine.patternsAvailable && quarantine.kernelAvailable
	selectorDivergenceWitness: kernelManifest.divergences.selectorGrammar.witness & #LocalCueSelectorExpr
})

fixtureSatisfaction: compatibilityFixtures.pinnedSourceIdentity &&
	compatibilityFixtures.localCopyIsDivergent &&
	compatibilityFixtures.metadataIsNotProof &&
	compatibilityFixtures.surfacesRemainAvailable &&
	compatibilityFixtures.selectorDivergenceWitness == "foo.#Bar"
