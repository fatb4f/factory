package s00

import "strings"

#NonEmptyString: string & strings.MinRunes(1)
#ID:             #NonEmptyString & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#RequirementID:  string & =~"^[A-Z]{2}-[0-9]{2}$"
#AcceptanceID:   string & =~"^[A-Z]{2}-[0-9]{2}-A[0-9]+$"
#GitCommit:      string & =~"^[0-9a-f]{40}$"
#SHA256:         string & =~"^[0-9a-f]{64}$"
#GitBlob:        string & =~"^[0-9a-f]{40}$"
#Scenario:       "positive" | "negative" | "invariant" | "compatibility" | "adversarial"
#Classification:
	"lattice-primitive" |
	"lattice-law" |
	"evaluation-consequence" |
	"application-pattern" |
	"fixture-protocol" |
		"metadata"
#SurfaceStatus: "provisional" | "admitted" | "failed" | "deferred" | "drifted"

#MatrixSnapshot: close({
	id:         "fatb4f/factory#107"
	marker:     "cue-lattice-conformance-requirements-matrix:v1"
	revision:   "v1"
	updatedAt:  string
	bodySHA256: #SHA256
})

#SourceIdentity: close({
	repository:   "https://github.com/fatb4f/lattice"
	revision:     #GitCommit
	retrieval:    "git-blob-at-commit"
	movingTarget: false
})

#PatternEntry: close({
	[F= !~"^(id|path|blob|contentSHA256|classification|status)$"]: {
		_invalidField: F & =~"^(id|path|blob|contentSHA256|classification|status)$"
	}

	id:             #ID
	path:           string & =~"^patterns/[a-z0-9-]+\\.cue$"
	blob:           #GitBlob
	contentSHA256:  #SHA256
	classification: #Classification
	status:         "provisional"
})

#PatternMetadataEntry: close({
	id:             "schema"
	path:           "patterns/schema.cue"
	blob:           #GitBlob
	contentSHA256:  #SHA256
	classification: "metadata"
	status:         "provisional"
	semanticProof:  false
})

#PatternInventory: close({
	id:     "lattice-pattern-inventory-v1"
	source: #SourceIdentity
	patterns: {[#ID]: #PatternEntry}
	metadata: close({schema: #PatternMetadataEntry})
	semanticCount: 16
	status:        "provisional"
})

#DependencyRef: close({
	id:       #ID
	status:   "provisional"
	admitted: false
})

#KernelManifest: close({
	id:                  "lattice-kernel-source-manifest-v1"
	source:              #SourceIdentity
	sourcePath:          "meta/kernel.cue"
	sourceBlob:          #GitBlob
	sourceContentSHA256: #SHA256
	localPath:           ".codex/skills/cue/contracts/kernel/kernel.cue"
	localContentSHA256:  #SHA256
	exportedDeclarations: [...string] & [_, ...]
	intentionalDivergences: [...close({
		id:          #ID
		description: #NonEmptyString
	})]
	patternDependencies: [...#DependencyRef] & [_, ...]
	conceptDependencies: [...#DependencyRef] & [_, ...]
	status: "provisional"
})

#RequirementRecord: close({
	id: #RequirementID
	dependsOn: [...#RequirementID]
	acceptance: #AcceptanceID
	scenarios: {[#Scenario]: true}
	order: int & >=0
})

#ImplementationUnit: close({
	id:     "issue-107-s00-v1"
	matrix: #MatrixSnapshot
	directRequirements: ["PT-01", "KR-01", "MG-01"]
	requirements: {[#RequirementID]: #RequirementRecord}
	validationDAG: [...#RequirementID] & [_, ...]
	directEvidence: close({
		"PT-01-A1": close({positive: #ID, negative: #ID, invariant: #ID})
		"KR-01-A1": close({positive: #ID, negative: #ID, compatibility: #ID})
		"MG-01-A1": close({positive: #ID, negative: #ID, compatibility: #ID})
	})
})

#QuarantineInput: close({
	patterns:              #SurfaceStatus
	kernel:                #SurfaceStatus
	prerequisitesAdmitted: bool
})

// Eligibility is derived from the inventories and prerequisite state. Callers
// cannot submit any of these conclusions as raw inventory data.
#QuarantineProjection: {
	Input:  #QuarantineInput
	_input: Input

	patternsAvailable: true
	kernelAvailable:   true
	if _input.patterns == "admitted" && _input.kernel == "admitted" && _input.prerequisitesAdmitted {
		downstreamEligible: true
		admissionEligible:  true
		noWideningEligible: true
	}
	if _input.patterns != "admitted" || _input.kernel != "admitted" || !_input.prerequisitesAdmitted {
		downstreamEligible: false
		admissionEligible:  false
		noWideningEligible: false
	}
}
