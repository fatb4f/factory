package ivaceval

import (
	"time"
	ivac "github.com/fatb4f/factory/contracts/personal/ivac:ivac"
)

#CriterionAssessment: close({
	criterionID: ivac.#ID
	disposition: #AssessmentDisposition
	observations: [...ivac.#ObservationRef]
	findings: [...ivac.#FindingRef]
	evidence: [...ivac.#EvidenceArtifactRef]
	missingEvidence: [...(string & !="")]
	rationale: string & !=""
	if disposition == "supported" {
		findings: [ivac.#FindingRef, ...ivac.#FindingRef]
		evidence: [ivac.#EvidenceArtifactRef, ...ivac.#EvidenceArtifactRef]
		missingEvidence: []
	}
	if disposition == "insufficient-evidence" {
		missingEvidence: [string & !="", ...(string & !="")]
	}
})

// Separate companion input/output: the v1 permanent-sequela contract and
// AssessmentBundle stay compatible. This is a candidate, never adjudication.
#RegulatoryQualification: {
	usage: "synthetic-test" | "case-assessment"
	if usage == "synthetic-test" {compendium: source: contentKind: "synthetic"}
	if usage == "case-assessment" {compendium: source: contentKind: "official"}
	case:       ivac.#ValidatedCasePlant
	compendium: ivac.#RegulatoryCompendium
	instance: #EvaluationInstance & {contract: {id: "permanent-sequela", version: "1.0.0"}}
	axis:          ivac.#ClaimAxisRef
	unitID:        ivac.#ID
	classID:       ivac.#ID
	alternativeID: ivac.#ID
	applicability: close({
		state:       "unresolved" | "selected"
		asOf:        ivac.#RegulatoryDate
		rationale:   string & !=""
		selectedBy?: ivac.#ActorRef
		if state == "selected" {selectedBy: ivac.#ActorRef}
	})
	causation: close({
		state: "unresolved" | "supported" | "contradicted"
		findings: [...ivac.#FindingRef]
		rationale: string & !=""
		if state == "supported" {findings: [ivac.#FindingRef, ...ivac.#FindingRef]}
	})
	assessments: [string]: #CriterionAssessment
	status:       "incomplete" | "qualified-candidate"
	adjudication: "not-determined"
	coverageGaps: [...(string & !="")]
	if status == "incomplete" {coverageGaps: [string & !="", ...(string & !="")]}

	// A concrete selector defers existence proofs until instance data is bound.
	if unitID != "" {
		_applicabilityDate: time.Parse("2006-01-02", applicability.asOf)

		let selectedAxis = axis
		_profile: instance.profile & {id: case.profile.id}
		_evaluator: [for id, a in case.review.actors if id == instance.evaluator.id {
			a & {kind: "medical-expert" | "treating-clinician"}
		}] & [_, ...]
		_axis: [for id, a in case.review.axes if id == axis.id {a}] & [_, ...]
		_units: [for id, u in compendium.units if id == unitID {u}] & [_, ...]
		_unit: _units[0]
		_classes: [for id, c in _unit.classes if id == classID {c}] & [_, ...]
		_class: _classes[0]
		_alternatives: [for a in _class.qualification.alternatives if a.id == alternativeID {a}] & [_, ...]
		_alternative: _alternatives[0]
		if applicability.state == "selected" {
			_selector: [for id, a in case.review.actors if id == applicability.selectedBy.id {
				a & {kind: "legal-representative"}
			}] & [_, ...]
			_start: applicability.asOf & >=compendium.source.effective.from
			if compendium.source.effective.end == "bounded" {
				_end: applicability.asOf & <compendium.source.effective.until
			}
		}
		_causalFindings: [for ref in causation.findings {
			_matches: [for id, f in case.review.findings if id == ref.id {
				f & {axis: selectedAxis, kind: "causal-opinion" | "aggravation-opinion"}
			}] & [_, ...]
		}]
		_assessmentIntegrity: [for id, a in assessments {
			_identity: a & {criterionID: id}
			_criterion: [for c in _alternative.criteria if c.id == id {c}] & [_, ...]
			_observations: [for ref in a.observations {
				_matches: [for oid, o in case.world.observations if oid == ref.id {o}] & [_, ...]
			}]
			_findings: [for ref in a.findings {
				_matches: [for fid, f in case.review.findings if fid == ref.id {f & {axis: selectedAxis}}] & [_, ...]
			}]
			_evidence: [for ref in a.evidence {
				_matches: [for eid, e in case.review.evidence if eid == ref.id {e}] & [_, ...]
			}]
		}]
		if status == "qualified-candidate" {
			compendium: review: state: "reviewed"
			applicability: state: "selected"
			causation: state:     "supported"
			_complete: [for c in _alternative.criteria {
				_matches: [for id, a in assessments if id == c.id {a & {disposition: "supported"}}] & [_, ...]
			}]
		}

	}
}
