package s00

import "list"

requirements: close({
	"UA-01": {id: "UA-01", dependsOn: [], acceptance: "UA-01-A1", scenarios: {positive: true, invariant: true}, order: 0}
	"UA-02": {id: "UA-02", dependsOn: ["UA-01"], acceptance: "UA-02-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 1}
	"UA-03": {id: "UA-03", dependsOn: ["UA-02"], acceptance: "UA-03-A1", scenarios: {positive: true, negative: true}, order: 2}
	"UA-04": {id: "UA-04", dependsOn: ["UA-03"], acceptance: "UA-04-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 3}
	"LT-01": {id: "LT-01", dependsOn: ["UA-04"], acceptance: "LT-01-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 4}
	"LT-02": {id: "LT-02", dependsOn: ["UA-04"], acceptance: "LT-02-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 5}
	"LT-03": {id: "LT-03", dependsOn: ["UA-04"], acceptance: "LT-03-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 6}
	"LT-04": {id: "LT-04", dependsOn: ["LT-01", "LT-02", "LT-03"], acceptance: "LT-04-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 7}
	"LT-05": {id: "LT-05", dependsOn: ["LT-01", "LT-02", "LT-03"], acceptance: "LT-05-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 8}
	"LT-06": {id: "LT-06", dependsOn: ["LT-04", "LT-05"], acceptance: "LT-06-A1", scenarios: {positive: true, negative: true, compatibility: true, invariant: true}, order: 9}
	"LT-07": {id: "LT-07", dependsOn: ["LT-01", "LT-05"], acceptance: "LT-07-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 10}
	"LT-08": {id: "LT-08", dependsOn: ["LT-01", "LT-04"], acceptance: "LT-08-A1", scenarios: {positive: true, negative: true, compatibility: true, adversarial: true}, order: 11}
	"ST-06": {id: "ST-06", dependsOn: ["UA-04", "LT-01"], acceptance: "ST-06-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 12}
	"ST-07": {id: "ST-07", dependsOn: ["UA-04"], acceptance: "ST-07-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 13}
	"ES-01": {id: "ES-01", dependsOn: ["UA-04", "LT-02"], acceptance: "ES-01-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 14}
	"ST-01": {id: "ST-01", dependsOn: ["UA-04", "LT-01"], acceptance: "ST-01-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 15}
	"ES-02": {id: "ES-02", dependsOn: ["ES-01", "ST-01", "ST-07"], acceptance: "ES-02-A1", scenarios: {positive: true, negative: true, adversarial: true}, order: 16}
	"ES-03": {id: "ES-03", dependsOn: ["ES-01", "LT-03"], acceptance: "ES-03-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 17}
	"ES-05": {id: "ES-05", dependsOn: ["ES-01", "ES-02", "ES-03"], acceptance: "ES-05-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 18}
	"LT-09": {id: "LT-09", dependsOn: ["LT-04", "LT-05", "LT-06", "LT-07", "LT-08", "ST-06", "ST-07", "ES-05"], acceptance: "LT-09-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 19}
	"PT-01": {id: "PT-01", dependsOn: ["UA-03", "LT-09"], acceptance: "PT-01-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 20}
	"CF-01": {id: "CF-01", dependsOn: ["UA-04", "ES-05"], acceptance: "CF-01-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 21}
	"CF-02": {id: "CF-02", dependsOn: ["CF-01", "UA-02"], acceptance: "CF-02-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 22}
	"CF-03": {id: "CF-03", dependsOn: ["CF-02", "LT-01"], acceptance: "CF-03-A1", scenarios: {positive: true, negative: true, compatibility: true, adversarial: true}, order: 23}
	"CF-04": {id: "CF-04", dependsOn: ["CF-02", "LT-04", "LT-05", "LT-06"], acceptance: "CF-04-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 24}
	"ST-02": {id: "ST-02", dependsOn: ["ST-01"], acceptance: "ST-02-A1", scenarios: {positive: true, negative: true, compatibility: true}, order: 25}
	"ST-03": {id: "ST-03", dependsOn: ["LT-01", "ST-01"], acceptance: "ST-03-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 26}
	"ST-04": {id: "ST-04", dependsOn: ["ST-01", "ST-03"], acceptance: "ST-04-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 27}
	"ST-05": {id: "ST-05", dependsOn: ["ST-01", "ST-02"], acceptance: "ST-05-A1", scenarios: {positive: true, negative: true, compatibility: true}, order: 28}
	"ES-04": {id: "ES-04", dependsOn: ["ES-01", "ST-01", "ST-04"], acceptance: "ES-04-A1", scenarios: {positive: true, negative: true, adversarial: true}, order: 29}
	"CF-05": {id: "CF-05", dependsOn: ["CF-02", "ST-02", "ST-03", "ST-04", "ST-05", "ST-06", "ST-07", "ES-02", "ES-03", "ES-04"], acceptance: "CF-05-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 30}
	"CF-06": {id: "CF-06", dependsOn: ["CF-02", "LT-02", "ES-02"], acceptance: "CF-06-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 31}
	"CF-07": {id: "CF-07", dependsOn: ["CF-03", "CF-04", "CF-05", "CF-06"], acceptance: "CF-07-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 32}
	"CF-08": {id: "CF-08", dependsOn: ["CF-07", "LT-09"], acceptance: "CF-08-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 33}
	"UA-05": {id: "UA-05", dependsOn: ["UA-02", "UA-04"], acceptance: "UA-05-A1", scenarios: {positive: true, negative: true, compatibility: true}, order: 34}
	"CF-09": {id: "CF-09", dependsOn: ["CF-08", "UA-05"], acceptance: "CF-09-A1", scenarios: {positive: true, negative: true, compatibility: true, adversarial: true}, order: 35}
	"PT-02": {id: "PT-02", dependsOn: ["PT-01", "CF-09"], acceptance: "PT-02-A1", scenarios: {positive: true, negative: true, invariant: true}, order: 36}
	"PT-03": {id: "PT-03", dependsOn: ["PT-02", "CF-03"], acceptance: "PT-03-A1", scenarios: {positive: true, negative: true, compatibility: true, adversarial: true}, order: 37}
	"PT-04": {id: "PT-04", dependsOn: ["PT-02", "CF-06"], acceptance: "PT-04-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 38}
	"PT-05": {id: "PT-05", dependsOn: ["PT-02", "LT-08", "CF-03"], acceptance: "PT-05-A1", scenarios: {positive: true, negative: true, compatibility: true, adversarial: true}, order: 39}
	"PT-06": {id: "PT-06", dependsOn: ["PT-02", "LT-07", "ST-02", "ST-07"], acceptance: "PT-06-A1", scenarios: {positive: true, negative: true, invariant: true, adversarial: true}, order: 40}
	"PT-07": {id: "PT-07", dependsOn: ["PT-03", "PT-04", "PT-05", "PT-06"], acceptance: "PT-07-A1", scenarios: {positive: true, negative: true, invariant: true, compatibility: true}, order: 41}
	"PT-08": {id: "PT-08", dependsOn: ["PT-07", "CF-09"], acceptance: "PT-08-A1", scenarios: {positive: true, negative: true, compatibility: true, invariant: true}, order: 42}
	"KR-01": {id: "KR-01", dependsOn: ["PT-08", "UA-02"], acceptance: "KR-01-A1", scenarios: {positive: true, negative: true, compatibility: true}, order: 43}
	"MG-01": {id: "MG-01", dependsOn: ["PT-01", "KR-01"], acceptance: "MG-01-A1", scenarios: {positive: true, negative: true, compatibility: true}, order: 44}
})

validationDAG: [
	"UA-01", "UA-02", "UA-03", "UA-04", "LT-01", "LT-02", "LT-03", "LT-04", "LT-05", "LT-06", "LT-07", "LT-08", "ST-06", "ST-07", "ES-01", "ST-01", "ES-02", "ES-03", "ES-05", "LT-09", "PT-01", "CF-01", "CF-02", "CF-03", "CF-04", "ST-02", "ST-03", "ST-04", "ST-05", "ES-04", "CF-05", "CF-06", "CF-07", "CF-08", "UA-05", "CF-09", "PT-02", "PT-03", "PT-04", "PT-05", "PT-06", "PT-07", "PT-08", "KR-01", "MG-01",
]

let matrixSnapshot = matrix
let requirementClosure = requirements
let declaredValidationDAG = validationDAG

unit: #ImplementationUnit & {
	id:     "issue-107-s00-v1"
	matrix: matrixSnapshot
	directRequirements: ["PT-01", "KR-01", "MG-01"]
	requirements:  requirementClosure
	validationDAG: declaredValidationDAG
	// Evidence and prerequisite admissions are transient, typed inputs. Empty
	// maps preserve quarantine until full runner-backed records are supplied.
	directEvidence: {}
	prerequisiteAdmissions: {}
}

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
_requiredDirectEvidenceScopeSet: {
	for requirementID in unit.directRequirements {
		let requirement = requirements[requirementID]
		for scenario, _ in requirement.scenarios {
			"\(requirement.acceptance):\(scenario)": true
		}
	}
}
requiredDirectEvidenceScopes: list.SortStrings([for scope, _ in _requiredDirectEvidenceScopeSet {scope}])
observedDirectEvidenceScopes: list.SortStrings([for _, evidence in unit.directEvidence {
	"\(evidence.acceptanceID):\(evidence.scenario)"
}])
_directEvidenceBindingProof: {
	for requirementID in unit.directRequirements {
		let requirement = requirements[requirementID]
		for evidenceID, evidence in unit.directEvidence if evidence.requirementID == requirementID {
			"\(evidenceID)-acceptance": evidence.acceptanceID & requirement.acceptance
			"\(evidenceID)-revision":   evidence.sourceRevision & source.revision
		}
	}
}

requiredPrerequisiteIDs: list.SortStrings([for id in selectedIDs if !list.Contains(unit.directRequirements, id) {id}])
providedPrerequisiteIDs: list.SortStrings([for id, _ in unit.prerequisiteAdmissions {id}])
let requiredPrerequisites = requiredPrerequisiteIDs
let prerequisiteAdmissionRecords = unit.prerequisiteAdmissions

closureComplete: len(selectedIDs) == 45 && len(_dependencyProof) == 218 &&
			len(_validationDAGProof) == len(selectedIDs)
directCoverageComplete: requiredDirectEvidenceScopes == observedDirectEvidenceScopes &&
	len(unit.directEvidence) == len(requiredDirectEvidenceScopes) &&
	len(_directEvidenceBindingProof) == 2*len(unit.directEvidence)

quarantine: #QuarantineProjection & {
	patternStatus:           patternInventory.status
	kernelStatus:            kernelManifest.status
	sourceRevision:          source.revision
	requiredPrerequisiteIDs: requiredPrerequisites
	prerequisiteAdmissions:  prerequisiteAdmissionRecords
}
prerequisitesAdmitted: quarantine.prerequisitesAdmitted

inventorySliceComplete: inventoryComplete && closureComplete && directCoverageComplete &&
	negativeFixtureEvaluationComplete &&
	!quarantine.downstreamEligible && !quarantine.admissionEligible &&
	!quarantine.noWideningEligible

unitAdmission: inventorySliceComplete && prerequisitesAdmitted

report: close({
	id:                      unit.id
	matrixRevision:          matrix.revision
	closureRequirementCount: len(selectedIDs)
	semanticPatternCount:    patternInventory.semanticCount
	metadataCount:           len(patternInventory.metadata)
	patternStatus:           patternInventory.status
	kernelStatus:            kernelManifest.status
	downstreamEligible:      quarantine.downstreamEligible
	admissionEligible:       quarantine.admissionEligible
	noWideningEligible:      quarantine.noWideningEligible
	implementationComplete:  inventorySliceComplete
	admitted:                unitAdmission
})
