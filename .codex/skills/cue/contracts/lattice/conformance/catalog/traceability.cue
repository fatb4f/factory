package catalog

import (
	"list"
	gatepkg "github.com/fatb4f/factory/cue-skill/gate"
	upstream "github.com/fatb4f/factory/cue-skill/lattice/conformance/upstream"
)

#RequirementID: string & =~"^[A-Z]{2}-[0-9]{2}$"
#AcceptanceID:  string & =~"^[A-Z]{2}-[0-9]{2}-A[0-9]+$"
#Scenario:      "positive" | "negative" | "invariant" | "compatibility" | "adversarial"
#EvidenceID:    string & =~"^[a-z0-9]+(-[a-z0-9]+)*$"
#SHA256:        string & =~"^[0-9a-f]{64}$"

#MatrixSnapshot: close({
	id:         "fatb4f/factory#107"
	marker:     "cue-lattice-conformance-requirements-matrix:v1"
	revision:   "v1"
	updatedAt:  string
	bodySHA256: #SHA256
})

#RequirementRecord: close({
	id: #RequirementID
	dependsOn: [...#RequirementID]
	acceptance: #AcceptanceID
	scenarios: {[#Scenario]: true}
	order: int & >=0
})

matrix: #MatrixSnapshot & {
	id:         "fatb4f/factory#107"
	marker:     "cue-lattice-conformance-requirements-matrix:v1"
	revision:   "v1"
	updatedAt:  "2026-07-13T15:05:57Z"
	bodySHA256: "6a32affbfd803849abdf2d79c16d5150cda38708257b84dfdae3ae374d69b61c"
}

requirements: close({
	"UA-01": {id: "UA-01", dependsOn: [], acceptance: "UA-01-A1", scenarios: {positive: true, invariant: true}, order: 0}
	"UA-02": {id: "UA-02", dependsOn: ["UA-01"], acceptance: "UA-02-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 1}
	"UA-03": {id: "UA-03", dependsOn: ["UA-02"], acceptance: "UA-03-A1", scenarios: {positive: true, negative: true}, order: 2}
	"UA-04": {id: "UA-04", dependsOn: ["UA-03"], acceptance: "UA-04-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 3}
})

validationDAG: ["UA-01", "UA-02", "UA-03", "UA-04"]

directEvidence: close({
	"UA-01-A1": {positive: "closed-source-class-boundary", invariant: "source-class-role-separation"}
	"UA-02-A1": {positive: "revision-bound-artifact-set", negative: "mutable-and-mismatch-fixtures", invariant: "engine-source-identity"}
	"UA-03-A1": {positive: "concept-source-reference-map", negative: "unknown-artifact-fixture"}
	"UA-04-A1": {positive: "closed-domain-neutral-catalog", negative: "application-vocabulary-fixture", invariant: "stable-concept-id-set"}
})

validationPlan: close({
	structural: [
		"cue fmt --check --files lattice/conformance",
		"cue vet -c=false ./lattice/conformance/...",
		"cue vet -c ./lattice/conformance/report",
	]
	negative: [
		"conjoin each upstream.negativeFixtures value with its declared target and require bottom",
		"conjoin each catalog.negativeFixtures value with its declared target and require bottom",
	]
	semantic: [
		"evaluate upstream.authorityPinned",
		"evaluate catalog.catalogComplete",
		"evaluate report.sliceAdmission",
	]
})

structuralGateEvaluation: gatepkg.#PackageGateEvaluation & {
	observations: [
		{
			id:              "format", template: "cue-fmt-check", exitCode: 0
			startedUnixNano: 0, elapsedNanos:    0, stdout:                 "", stderr: ""
		},
		{
			id:              "vet-structural", template: "cue-vet-structural", exitCode: 0
			startedUnixNano: 0, elapsedNanos:            0, stdout:                      "", stderr: ""
		},
		{
			id:              "vet-concrete", template: "cue-vet-concrete", exitCode: 0
			startedUnixNano: 0, elapsedNanos:          0, stdout:                    "", stderr: ""
		},
	]
}
structuralGatesComplete: structuralGateEvaluation.structuralComplete && structuralGateEvaluation.allSucceeded

selectedIDs: list.SortStrings([for id, _ in requirements {id}])
_dependencyProof: {
	for id, requirement in requirements {
		for dependency in requirement.dependsOn {
			"\(id)-contains-\(dependency)": list.Contains(selectedIDs, dependency) & true
			"\(dependency)-before-\(id)":   requirements[dependency].order < requirement.order
		}
	}
}
_validationDAGProof: {
	for order, requirementID in validationDAG {
		"\(requirementID)-order": requirements[requirementID].order & order
	}
}
_directCoverageProof: {
	for requirementID, requirement in requirements {
		for scenario, _ in requirement.scenarios {
			"\(requirement.acceptance)-\(scenario)": directEvidence[requirement.acceptance][scenario] & #EvidenceID
		}
	}
}

closureComplete: selectedIDs == validationDAG && len(selectedIDs) == 4 &&
			len(_dependencyProof) == 6 && len(_validationDAGProof) == 4
directCoverageComplete: len(_directCoverageProof) == 10

sliceComplete: upstream.authorityPinned && upstream.authorityFixtureSatisfaction &&
	catalogComplete && catalogFixtureSatisfaction && closureComplete && directCoverageComplete &&
		structuralGatesComplete
sliceAdmission: sliceComplete
