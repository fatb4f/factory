package s00

// Raw adversarial inputs remain separate from their explicit target schemas.
// Validation commands conjoin only the selected fixture with its target.
negativeFixtures: close({
	mutableSource: {
		target: "#SourceIdentity"
		value: {
			repository:   "https://github.com/fatb4f/lattice"
			revision:     "main"
			retrieval:    "git-blob-at-commit"
			movingTarget: true
		}
	}
	copiedKernelClaim: {
		target: "#KernelManifest"
		value: {status: "admitted"}
	}
	unknownPatternField: {
		target: "#PatternEntry"
		value: {
			id:             "attributes", path: "patterns/attributes.cue"
			blob:           "274a95c29c03a74f6c6d6e3de6c2d4ee02026a3d"
			contentSHA256:  "28a96a79bbe1a5383001e538ce0e56d22f345bc5929da35ffbadef9278b233b2"
			classification: "application-pattern", status: "provisional"
			admitted:       true
		}
	}
	claimedAdmission: {
		target: "#QuarantineProjection"
		value: {
			Input: {patterns: "provisional", kernel: "provisional", prerequisitesAdmitted: false}
			patternsAvailable:  true
			kernelAvailable:    true
			downstreamEligible: false
			admissionEligible:  true
			noWideningEligible: false
		}
	}
})

compatibilityFixtures: close({
	pinnedSourceIdentity:    source.revision == "4148dc1a2d1adfa0782e93e89ea402ce41c56d35"
	localCopyIsDivergent:    kernelManifest.sourceContentSHA256 != kernelManifest.localContentSHA256
	metadataIsNotProof:      patternInventory.metadata.schema.semanticProof == false
	surfacesRemainAvailable: quarantine.patternsAvailable && quarantine.kernelAvailable
})

fixtureSatisfaction: compatibilityFixtures.pinnedSourceIdentity &&
	compatibilityFixtures.localCopyIsDivergent &&
	compatibilityFixtures.metadataIsNotProof &&
	compatibilityFixtures.surfacesRemainAvailable
