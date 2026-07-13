package s00

import (
	"list"
	"strings"

	evalpkg "github.com/fatb4f/factory/cue-skill/eval"
	kernel "github.com/fatb4f/factory/cue-skill/kernel"
	observationpkg "github.com/fatb4f/factory/cue-skill/observation"
	subjectpkg "github.com/fatb4f/factory/cue-skill/subject"
)

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
#ArtifactRole:  "fixture" | "runner-request" | "probe-observation" | "probe-evaluation"

// The upstream selector grammar permits a definition marker only in the first
// segment. The skill-local kernel deliberately has a wider grammar.
#SourceCueSelectorExpr: #NonEmptyString & =~"^[_#A-Za-z][_A-Za-z0-9]*(\\.[_A-Za-z][_A-Za-z0-9]*)*$"
#LocalCueSelectorExpr:  kernel.#CueSelectorExpr

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

#ExportMapping: close({
	source:                  string & =~"^#[A-Za-z][_A-Za-z0-9]*$"
	localCompatibilityAlias: string & =~"^#[A-Za-z][_A-Za-z0-9]*$"
	localReplacement:        string & =~"^#[A-Za-z][_A-Za-z0-9]*$"
})

#KernelDivergences: close({
	exactKeyCompatibilityName: close({
		description: #NonEmptyString
	})
	selectorGrammar: close({
		source:  #NonEmptyString
		local:   #NonEmptyString
		witness: #LocalCueSelectorExpr
	})
})

#KernelManifest: close({
	id:                  "lattice-kernel-source-manifest-v1"
	source:              #SourceIdentity
	sourcePath:          "meta/kernel.cue"
	sourceBlob:          #GitBlob
	sourceContentSHA256: #SHA256
	localPath:           ".codex/skills/cue/contracts/kernel/kernel.cue"
	localContentSHA256:  #SHA256
	sourceExportedDeclarations: [...string] & [_, ...]
	localExportedDeclarations: [...string] & [_, ...]
	exportMapping: close({
		"#NoWideningProof": #ExportMapping
	})
	divergences: #KernelDivergences
	patternDependencies: [...#DependencyRef] & [_, ...]
	conceptDependencies: [...#DependencyRef] & [_, ...]
	status: "provisional"

	_sourceExportsUnique: list.UniqueItems(sourceExportedDeclarations) & true
	_localExportsUnique:  list.UniqueItems(localExportedDeclarations) & true
})

// These are producer facts, not the manifest's own declaration claims. A
// complete inventory requires one independently produced observation for each
// source role and exact equality with the corresponding manifest set.
#DeclarationInventoryObservation: close({
	id:       #ID
	role:     "source" | "local"
	path:     #NonEmptyString
	producer: "cue-definition-inventory/v1"
	declarations: [...string] & [_, ...]

	_declarationsUnique: list.UniqueItems(declarations) & true
})

#RequirementRecord: close({
	id: #RequirementID
	dependsOn: [...#RequirementID]
	acceptance: #AcceptanceID
	scenarios: {[#Scenario]: true}
	order: int & >=0
})

#EvidenceArtifact: close({
	id:     #ID
	role:   #ArtifactRole
	digest: #SHA256
})

#CommandEvidence: close({
	id:                  #ID
	protocol:            "cueprobe/v1"
	fixtureArtifact:     #ID
	requestArtifact:     #ID
	observationArtifact: #ID
})

// Evidence is a full, revision-bound proof chain. The typed evaluation is the
// separately exportable projection of the package evaluator and is bound to
// the same structured subject and observation identity here.
#EvidenceRecord: close({
	id:             #ID
	requirementID:  #RequirementID
	acceptanceID:   #AcceptanceID
	scenario:       #Scenario
	sourceRevision: #GitCommit

	artifacts: close({
		fixture: #EvidenceArtifact & {role: "fixture", id: =~"^fixture-"}
		request: #EvidenceArtifact & {role: "runner-request", id: =~"^request-"}
		observation: #EvidenceArtifact & {role: "probe-observation", id: =~"^observation-"}
		evaluation: #EvidenceArtifact & {role: "probe-evaluation", id: =~"^evaluation-"}
	})
	command:       #CommandEvidence
	subject:       subjectpkg.#ProbeSubject
	subjectDigest: subjectpkg.#Digest
	engine: close({
		id:      "cue-go-api"
		version: #NonEmptyString
	})
	observation: observationpkg.#ProbeObservation
	evaluation:  evalpkg.#ProbeEvaluationShape

	_artifacts:     artifacts
	_subject:       subject
	_subjectDigest: subjectDigest
	_observation:   observation
	_evaluation:    evaluation
	_command:       command

	_command: {
		fixtureArtifact:     _artifacts.fixture.id
		requestArtifact:     _artifacts.request.id
		observationArtifact: _artifacts.observation.id
	}
	_observation: {
		subject:       _subject
		subjectDigest: _subjectDigest
		adapter: {
			id:            engine.id
			engineVersion: engine.version
		}
	}
	_evaluation: {
		probeID:          _observation.probeID
		candidate:        _subject.candidate.id
		subject:          _subject
		identityValid:    true
		evidenceComplete: true
		satisfied:        true
	}
})

#RequirementAdmissionShape: close({
	requirement:    #RequirementRecord
	sourceRevision: #GitCommit
	evidence: close({[ID=string]: #EvidenceRecord & {id: ID}})
	admitted: bool
})

#RequirementAdmission: #RequirementAdmissionShape & {
	requirement:    #RequirementRecord
	sourceRevision: #GitCommit
	evidence: close({[ID=string]: #EvidenceRecord & {id: ID}})
	_requirement: requirement
	_evidence:    evidence
	_requiredScenarios: list.SortStrings([for scenario, _ in _requirement.scenarios {scenario}])
	_observedScenarios: list.SortStrings([for _, record in _evidence {record.scenario}])
	_bindingProof: {
		for _, record in _evidence {
			"\(record.id)-requirement": record.requirementID & _requirement.id
			"\(record.id)-acceptance":  record.acceptanceID & _requirement.acceptance
			"\(record.id)-revision":    record.sourceRevision & sourceRevision
		}
	}

	admitted: _requiredScenarios == _observedScenarios &&
		len(_evidence) == len(_requiredScenarios) &&
		len(_bindingProof) == 3*len(_evidence)
}

#ImplementationUnit: close({
	id:     "issue-107-s00-v1"
	matrix: #MatrixSnapshot
	directRequirements: ["PT-01", "KR-01", "MG-01"]
	requirements: {[#RequirementID]: #RequirementRecord}
	validationDAG: [...#RequirementID] & [_, ...]
	directEvidence: close({[ID=string]: #EvidenceRecord & {id: ID}})
	prerequisiteAdmissions: close({[ID=#RequirementID]: #RequirementAdmission & {
		requirement: {id: ID}
	}})
})

// Eligibility is derived from typed prerequisite admissions. There is no raw
// Boolean that a caller can flip to transition the unit to admitted.
#QuarantineProjectionShape: close({
	patternStatus:  #SurfaceStatus
	kernelStatus:   #SurfaceStatus
	sourceRevision: #GitCommit
	requiredPrerequisiteIDs: [...#RequirementID]
	prerequisiteAdmissions: close({[ID=#RequirementID]: #RequirementAdmission & {
		requirement: {id: ID}
	}})
	patternsAvailable:     bool
	kernelAvailable:       bool
	prerequisitesAdmitted: bool
	downstreamEligible:    bool
	admissionEligible:     bool
	noWideningEligible:    bool
})

#QuarantineProjection: #QuarantineProjectionShape & {
	patternStatus:  #SurfaceStatus
	kernelStatus:   #SurfaceStatus
	sourceRevision: #GitCommit
	requiredPrerequisiteIDs: [...#RequirementID]
	prerequisiteAdmissions: close({[ID=#RequirementID]: #RequirementAdmission & {
		requirement: {id: ID}
	}})
	_required: list.SortStrings(requiredPrerequisiteIDs)
	_provided: list.SortStrings([for id, _ in prerequisiteAdmissions {id}])
	_revisionProof: {
		for id, admission in prerequisiteAdmissions {
			"\(id)-revision": admission.sourceRevision & sourceRevision
		}
	}
	prerequisitesAdmitted: _required == _provided &&
		len(_revisionProof) == len(_required) &&
		!list.Contains([for _, admission in prerequisiteAdmissions {admission.admitted}], false)

	patternsAvailable: true
	kernelAvailable:   true
	if patternStatus == "admitted" && kernelStatus == "admitted" && prerequisitesAdmitted {
		downstreamEligible: true
		admissionEligible:  true
		noWideningEligible: true
	}
	if patternStatus != "admitted" || kernelStatus != "admitted" || !prerequisitesAdmitted {
		downstreamEligible: false
		admissionEligible:  false
		noWideningEligible: false
	}
}

#NegativeFixtureEvaluationShape: close({
	fixtureID: #ID
	evidence:  #EvidenceRecord
	satisfied: bool
})

#NegativeFixtureEvaluation: #NegativeFixtureEvaluationShape & {
	evidence:  #EvidenceRecord
	_evidence: evidence
	_evidence: {
		scenario: "negative"
		observation: {operation: "ingress-reject"}
		evaluation: {
			verdict:   "bottoms"
			satisfied: true
		}
	}
	satisfied: _evidence.evaluation.satisfied
}
